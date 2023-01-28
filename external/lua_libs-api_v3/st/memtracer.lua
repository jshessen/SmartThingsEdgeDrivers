-- Copyright (c) 2021 SmartThings.
local log = require "log"
local memtracer = {}

memtracer.require_tracer = {}
_G.memtracer_metrics = {}

local require_tree_root = {
    name = "(root)",
    size = 0,
    total_size = 0,
    depth = 0,
    children = {},
    parent = nil
}

local orig_require = _G.require
local parent = require_tree_root

function memtracer.get_metrics_holder_with_namespace(namespace)
    if _G.memtracer_metrics[namespace] then
        return _G.memtracer_metrics[namespace]
    else
        local metrics_holder = {samplers = {}, current_sampler_idx = 1}

        metrics_holder.add_sampler = function(sampler)
            local current_idx = metrics_holder.current_sampler_idx
            metrics_holder.samplers[current_idx] = sampler
            metrics_holder.current_sampler_idx = current_idx + 1
        end

        _G.memtracer_metrics[namespace] = metrics_holder
        return metrics_holder
    end
end

function memtracer.print_metrics_for_namespace(namespace)
    local metrics_holder = _G.memtracer_metrics[namespace]

    if metrics_holder then
        for _, sampler in pairs(metrics_holder.samplers) do
            sampler.print_samples()
        end
    end
end

function memtracer.instrument_function(other_func, name)

    local metrics = {
        name = name or "wrapped_function",
        samples = {},
        last_sample_index = 1
    }

    metrics.print_samples = function()
        log.info_with({ hub_logs = true }, metrics.name .. "_memory_used_bytes,")
        for _, sample in pairs(metrics.samples) do
            log.info_with({ hub_logs = true }, string.format("%f,", sample.memory_used_bytes))
        end
    end

    local wrapped = function(...)
        -- double collect to handle resurrection/finalizers
        collectgarbage("collect")
        collectgarbage("collect")

        -- count before calling
        local start_mem = collectgarbage("count")

        local ret = other_func(...)

        -- count after calling without collecting to collect metrics
        local end_mem = collectgarbage("count")

        metrics.samples[metrics.last_sample_index] = {
            memory_used_bytes = (end_mem - start_mem) * 1024
        }

        metrics.last_sample_index = metrics.last_sample_index + 1

        return ret
    end

    return wrapped, metrics
end

function memtracer.require_tracer.iter(node)
    node = node or require_tree_root
    local i = 0
    local emitted_first_node = false
    local iter = nil
    return function()
        if not emitted_first_node then
            emitted_first_node = true
            return node
        end

        if iter then
            local res = iter()
            if not res then
                iter = nil
            else
                return res
            end
        end

        i = i + 1
        if i <= #node.children then
            local child = node.children[i]
            iter = memtracer.require_tracer.iter(child)
            local res = iter()
            return res
        end
        return nil
    end
end

local function name_chain(node)
    local names = {}
    local next_node = node
    while next_node ~= nil do
        table.insert(names, 1, next_node.name)
        next_node = next_node.parent
    end
    return names
end

function memtracer.require_tracer.generate_flamegraph()
    print(require_tree_root.name .. ": " .. #require_tree_root.children)
    for node in memtracer.require_tracer.iter(require_tree_root) do
        print(table.concat(name_chain(node), ";") .. " " ..
                  math.max(0, math.floor(node.size * 1024)))
    end
end

function memtracer.require_tracer.print_node_tree()
    for node in memtracer.require_tracer.iter(require_tree_root) do
        print(string.rep('  ', node.depth) .. node.name .. ': ' ..
                  math.floor(node.size * 1024))
    end
end

local function compute_depth(node)
    local depth = 0
    local next_node = node.parent
    while next_node do
        depth = depth + 1
        next_node = next_node.parent
    end
    return depth
end

local function size_of_all_descendents(node)
    local sum = 0
    for _, child_node in ipairs(node.children) do
        -- add the size of this node and recurse
        sum = sum + child_node.size + size_of_all_descendents(child_node)
    end
    return sum
end

function memtracer.require_tracer.install()
    _G.require = function(name)
        -- if already seen, do not mess with the require tree at all
        local package_from_cache = package.loaded[name]
        if package_from_cache then return package_from_cache end

        local node = {
            name = name,
            size = 0,
            total_size = 0,
            children = {},
            parent = parent,
            depth = compute_depth(parent) + 1
        }
        table.insert(parent.children, node)
        parent = node

        -- double collect to handle resurrection/finalizers
        collectgarbage("collect")
        collectgarbage("collect")

        -- count before doing require
        local start_mem = collectgarbage("count")

        -- do the actual require (will recurse into children)
        local res = orig_require(name)

        -- collect and count after doing the require of this module and children
        collectgarbage("collect")
        collectgarbage("collect")
        local end_mem = collectgarbage("count")

        -- the allocations for this node is the total minus descendents
        node.total_size = end_mem - start_mem
        local size_dependents = size_of_all_descendents(node)
        node.size = node.total_size - size_dependents

        -- going back up the stack
        parent = node.parent

        return res
    end
    return require_tree_root
end

function memtracer.require_tracer.uninstall() _G.require = orig_require end

return memtracer
