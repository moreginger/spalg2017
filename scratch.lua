require 'arc'

function testIntersectsArc(name, query, static, expect)
    print('testing', name, '...')
    if expect ~= query:intersectsArc(static) then
        print('failed')
        print('')
        love.event.quit()
    end
end

function scratch()
    base = Arc:new({ x = 0, y = 0, radius = 100, start_rads = 0, end_rads = 2 * math.pi})

    testIntersectsArc('coincident circles', base, base, true)
    testIntersectsArc('touching circles 1', base:new({x = 200}), base, true)
    testIntersectsArc('touching circles 2', base, base:new({x = 200}), true)
    testIntersectsArc('touching circles 3', base:new({y = 200}), base, true)
    testIntersectsArc('touching circles 4', base, base:new({y = 200}), true)
    testIntersectsArc('intersecting circles 1', base, base:new({x = 100}), true)
    testIntersectsArc('intersecting circles 2', base:new({x = 100}), base, true)
    testIntersectsArc('disjoint circles 1', base:new({x = 1000}), base, false)
    testIntersectsArc('disjoint circles 2', base, base:new({x = 1000}), false)

    half_left_acw = base:new({ start_rads = math.pi / 2, end_rads = math.pi * 3 / 2 })
    half_lower_acw = base:new({ end_rads = math.pi })
    half_upper_acw = base:new({ start_rads = math.pi, end_rads = math.pi * 2 })
    half_right_cw = base:new({ start_rads = math.pi / 2, end_rads = -math.pi / 2 })
    lower_right_acw = base:new({ end_rads = math.pi / 2 })
    upper_left_acw = base:new({ start_rads = math.pi, end_rads = math.pi * 3 / 2 })

    testIntersectsArc('concentric arcs 1', half_lower_acw, half_left_acw, true)
    testIntersectsArc('concentric arcs 2', half_left_acw, half_lower_acw, false)
    testIntersectsArc('concentric arcs 3', lower_right_acw, upper_left_acw, false)

    testIntersectsArc('touching arcs 1', half_lower_acw, half_upper_acw:new({y = 200}), true)
    testIntersectsArc('touching arcs 2', half_upper_acw:new({y = 200}), half_lower_acw, true)

    -- print('testing touching arcs...')
    -- if not lower_half:new({x = 0}):intersectsArc(lower_half) then fail() end

    -- print('testing intersecting arcs...')
    -- if not lower_half:new({x = 100}):intersectsArc(lower_half) then fail() end

    -- print('testing disjoint arcs...')
    -- if lower_half:new({x = 1000}):intersectsArc(lower_half) then fail() end

    -- print('testing disjoint arcs on same circle...')
    -- if lower_right:intersectsArc(upper_left) then fail() end
    -- print('flipped...')
    -- if upper_left:intersectsArc(lower_right) then fail() end

    print('finished testing')
    print('')
    io.read()
end
