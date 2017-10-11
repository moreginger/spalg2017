require 'arc'

failed = 0

function testIntersectsArc(name, query, static, expect)
    print('testing', name, '...')
    if expect ~= query:intersectsArc(static) then
        print('!!!FAILED!!!')
        print('')
        failed = failed + 1
    end
end

function test()
    base = Arc:new({ x = 0, y = 0, radius = 100, start_rads = 0, end_rads = 2 * math.pi})

    testIntersectsArc('coincident circles', base, base, 1)
    testIntersectsArc('touching circles 1', base:new({x = 200}), base, 1)
    testIntersectsArc('touching circles 2', base, base:new({x = 200}), 1)
    testIntersectsArc('touching circles 3', base:new({y = 200}), base, 1)
    testIntersectsArc('touching circles 4', base, base:new({y = 200}), 1)
    testIntersectsArc('intersecting circles 1', base, base:new({x = 100}), 2)
    testIntersectsArc('intersecting circles 2', base:new({x = 100}), base, 2)
    testIntersectsArc('disjoint circles 1', base:new({x = 1000}), base, 0)
    testIntersectsArc('disjoint circles 2', base, base:new({x = 1000}), 0)

    half_left_acw = base:new({ start_rads = math.pi / 2, end_rads = math.pi * 3 / 2 })
    half_lower_acw = base:new({ end_rads = math.pi })
    half_upper_acw = base:new({ start_rads = math.pi, end_rads = math.pi * 2 })
    half_right_cw = base:new({ start_rads = math.pi / 2, end_rads = -math.pi / 2 })
    lower_right_acw = base:new({ end_rads = math.pi / 2 })
    upper_left_acw = base:new({ start_rads = math.pi, end_rads = math.pi * 3 / 2 })

    testIntersectsArc('concentric arcs 1', half_lower_acw, half_left_acw, 1)
    testIntersectsArc('concentric arcs 2', half_left_acw, half_lower_acw, 0) -- concentric arcs are special. One arc "ahead" of other
    testIntersectsArc('concentric arcs disjoint', lower_right_acw, upper_left_acw, 0)

    testIntersectsArc('touching arcs 1', half_lower_acw, half_upper_acw:new({y = 200}), 1)
    testIntersectsArc('touching arcs 2', half_upper_acw:new({y = 200}), half_lower_acw, 1)

    testIntersectsArc('intersecting arcs 1', half_lower_acw, half_upper_acw:new({y = 100}), 2)
    testIntersectsArc('intersecting arcs 2', half_upper_acw:new({y = 100}), half_lower_acw, 2)
    testIntersectsArc('intersecting arcs 3', half_lower_acw, half_upper_acw:new({x = 10, y = 100}), 2)
    testIntersectsArc('intersecting arcs 4', half_upper_acw:new({x = 10, y = 100}), half_lower_acw, 2)

    -- testIntersectsArc('disjoint arcs 1', half_upper_acw:new({x = 10, y = 10}), half_lower_acw, false)
    testIntersectsArc('disjoint arcs 2', half_upper_acw:new({x = 150, y = 150}), half_lower_acw, 0)

    testIntersectsArc('real intersect 1', Arc:new({x = 393, y = 263, start_rads = 4.7, end_rads = 1.0, radius = 37.5}), Arc:new({x = 340, y = 306, start_rads = 3.6, end_rads = -1.1, radius = 37.5}), 1)
    testIntersectsArc('real intersect 2', Arc:new({x = 393, y = 263, start_rads = 4.7, end_rads = 1.2, radius = 37.5}), Arc:new({x = 340, y = 306, start_rads = 3.6, end_rads = -1.1, radius = 37.5}), 1)

    testIntersectsArc('real intersect 3', Arc:new({x = 217, y = 245, start_rads = 8.4, end_rads = 6.5, radius = 37.5}), Arc:new({x = 251, y = 292, start_rads = 3.8, end_rads = 3.2, radius = 37.5}), 1)
    testIntersectsArc('real intersect 4', Arc:new({x = 217, y = 245, start_rads = 8.4, end_rads = 6.6, radius = 37.5}), Arc:new({x = 251, y = 292, start_rads = 3.8, end_rads = 3.2, radius = 37.5}), 1)

    testIntersectsArc('different radius 1', base:new({x = 100, radius = 50, start_rads = math.pi / 2, end_rads = math.pi * 3 / 2}), base:new({start_rads = - math.pi / 2, end_rads = math.pi / 2}), 2)
    testIntersectsArc('different radius 2', base:new({x = 60, radius = 50, start_rads = math.pi / 2, end_rads = math.pi * 3 / 2}), base:new({start_rads = - math.pi / 2, end_rads = math.pi / 2}), 0)
    testIntersectsArc('different radius 3', base:new({x = 118, y = 269, radius = 37.5, start_rads = 0.07, end_rads = 0.24}), base:new({x = 400, y = 300, radius = 300, start_rads = 0, end_rads = math.pi * 2}), 0)

    print('')
    print('*** FINISHED TESTING ***')
    print('')

    if failed > 0 then
        print('Failed ' .. failed .. ' tests.')
        io.read()
    end
end
