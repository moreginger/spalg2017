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
    testIntersectsArc('concentric arcs 2', half_left_acw, half_lower_acw, false) -- concentric arcs are special. One arc "ahead" of other
    testIntersectsArc('concentric arcs disjoint', lower_right_acw, upper_left_acw, false)

    testIntersectsArc('touching arcs 1', half_lower_acw, half_upper_acw:new({y = 200}), true)
    testIntersectsArc('touching arcs 2', half_upper_acw:new({y = 200}), half_lower_acw, true)

    testIntersectsArc('intersecting arcs 1', half_lower_acw, half_upper_acw:new({y = 100}), true)
    testIntersectsArc('intersecting arcs 2', half_upper_acw:new({y = 100}), half_lower_acw, true)
    testIntersectsArc('intersecting arcs 3', half_lower_acw, half_upper_acw:new({x = 10, y = 100}), true)
    testIntersectsArc('intersecting arcs 4', half_upper_acw:new({x = 10, y = 100}), half_lower_acw, true)

    testIntersectsArc('disjoint arcs 1', half_upper_acw:new({x = 10, y = 10}), half_lower_acw, false)
    testIntersectsArc('disjoint arcs 1', half_upper_acw:new({x = 150, y = 150}), half_lower_acw, false)

    print('finished testing')
    print('')
    io.read()
end
