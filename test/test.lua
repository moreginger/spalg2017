require 'arc'

local failed = 0

function testIntersectsArc(name, query, static, expect)
    print(name .. '...')
    local result = query:intersectsArc(static)
    if expect ~= result then
        print('!!!FAILED!!! Expected ' .. expect .. ' but was ' .. result)
        print('')
        failed = failed + 1
        return
    end
    
end

function test()
    print('*** RUNNING TESTS ***')
    print('')

    local base = Arc:new({ x = 0, y = 0, radius = 100, start_rads = 0, end_rads = 2 * math.pi, total_rads = 2 * math.pi, player = 1})

    testIntersectsArc('coincident circles', base, base:new({ player = 2 }), 1)
    testIntersectsArc('touching circles 1', base:new({ x = 200 }), base:new({ player = 2 }), 1)
    testIntersectsArc('touching circles 2', base, base:new({ player = 2, x = 200 }), 1)
    testIntersectsArc('touching circles 3', base:new({ y = 200 }), base:new({ player = 2 }), 1)
    testIntersectsArc('touching circles 4', base, base:new({ player = 2, y = 200 }), 1)
    testIntersectsArc('intersecting circles 1', base, base:new({ player = 2, x = 100 }), 2)
    testIntersectsArc('intersecting circles 2', base:new({ x = 100 }), base:new({ player = 2 }), 2)
    testIntersectsArc('disjoint circles 1', base:new({ x = 1000 }), base:new({ player = 2 }), 0)
    testIntersectsArc('disjoint circles 2', base, base:new({ player = 2, x = 1000 }), 0)

    local half_left_acw = base:new({ start_rads = math.pi / 2, end_rads = math.pi * 3 / 2 })
    local half_lower_acw = base:new({ end_rads = math.pi })
    local half_upper_acw = base:new({ start_rads = math.pi, end_rads = math.pi * 2 })
    local half_right_cw = base:new({ start_rads = math.pi / 2, end_rads = -math.pi / 2 })
    local lower_right_acw = base:new({ end_rads = math.pi / 2 })
    local upper_left_acw = base:new({ start_rads = math.pi, end_rads = math.pi * 3 / 2 })

    testIntersectsArc('concentric arcs 1', half_lower_acw, half_left_acw:new({ player = 2 }), 1)
    testIntersectsArc('concentric arcs 2', half_left_acw, half_lower_acw:new({ player = 2 }), 0) -- concentric arcs are special. One arc "ahead" of other
    testIntersectsArc('concentric arcs disjoint', lower_right_acw, upper_left_acw:new({ player = 2 }), 0)

    testIntersectsArc('touching arcs 1', half_lower_acw, half_upper_acw:new({ player = 2, y = 200 }), 1)
    testIntersectsArc('touching arcs 2', half_upper_acw:new({ y = 200 }), half_lower_acw:new({ player = 2 }), 1)

    testIntersectsArc('intersecting arcs 1', half_lower_acw, half_upper_acw:new({ player = 2, y = 100}), 2)
    testIntersectsArc('intersecting arcs 2', half_upper_acw:new({ y = 100 }), half_lower_acw:new({ player = 2 }), 2)
    testIntersectsArc('intersecting arcs 3', half_lower_acw, half_upper_acw:new({ player = 2, x = 10, y = 100 }), 2)
    testIntersectsArc('intersecting arcs 4', half_upper_acw:new({ x = 10, y = 100 }), half_lower_acw:new({ player = 2 }), 2)

    testIntersectsArc('disjoint arcs 1', half_upper_acw:new({ x = 10, y = 10 }), half_lower_acw:new({ player = 2}), 0)
    testIntersectsArc('disjoint arcs 2', half_upper_acw:new({ x = 150, y = 150 }), half_lower_acw:new({ player = 2}), 0)

    testIntersectsArc('different radius 1', base:new({ x = 100, radius = 50, start_rads = math.pi / 2, end_rads = math.pi * 3 / 2 }), base:new({ player = 2, start_rads = - math.pi / 2, end_rads = math.pi / 2 }), 2)
    testIntersectsArc('different radius 2', base:new({ x = 60, radius = 50, start_rads = math.pi / 2, end_rads = math.pi * 3 / 2 }), base:new({ player = 2, start_rads = - math.pi / 2, end_rads = math.pi / 2 }), 0)
    testIntersectsArc('different radius 3', base:new({ x = 118, y = 269, radius = 37.5, start_rads = 0.07, end_rads = 0.24 }), base:new({ player = 2, x = 400, y = 300, radius = 300, start_rads = 0, end_rads = math.pi * 2 }), 0)


    local same_arc = base:new({ end_rads = 2 * math.pi - 0.1, total_rads = 2 * math.pi - 0.1 })
    testIntersectsArc('same arc < 2pi', same_arc, same_arc, 0)
    same_arc = base:new({ end_rads = 2 * math.pi, total_rads = 2 * math.pi })
    testIntersectsArc('same arc 2pi', same_arc, same_arc, 1)

    -- "REAL" tests taken from actual game data.
    local real_base = Arc:new({ player = 1, radius = 37.5 })

    testIntersectsArc('real intersect 1', real_base:new({ x = 393, y = 263, start_rads = 4.7, end_rads = 1.0 }), real_base:new({ player = 2, x = 340, y = 306, start_rads = 3.6, end_rads = -1.1 }), 1)
    testIntersectsArc('real intersect 2', real_base:new({ x = 393, y = 263, start_rads = 4.7, end_rads = 1.2 }), real_base:new({ player = 2, x = 340, y = 306, start_rads = 3.6, end_rads = -1.1 }), 1)

    testIntersectsArc('real intersect 3', real_base:new({ x = 217, y = 245, start_rads = 8.4, end_rads = 6.5 }), real_base:new({ player = 2, x = 251, y = 292, start_rads = 3.8, end_rads = 3.2 }), 1)
    testIntersectsArc('real intersect 4', real_base:new({ x = 217, y = 245, start_rads = 8.4, end_rads = 6.6 }), real_base:new({ player = 2, x = 251, y = 292, start_rads = 3.8, end_rads = 3.2 }), 1)

    testIntersectsArc(
        'real same player 1',
        real_base:new({ x = 602, y = 197, direction = 'acw', total_rads = 10.3, start_rads = 10.74, end_rads = 10.1 }),
        real_base:new({ x = 545, y = 155, direction = 'cw', total_rads = 5.1, start_rads = 5.5, end_rads = 10.6 }),
        1
    )

    print('')
    print('*** FINISHED TESTING ***')
    print('')

    if failed == 0 then
        print('Success!')
        return 0
    end
    
    print('Failed ' .. failed .. ' tests.')
    return 1
end
