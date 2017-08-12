require 'arc'

function fail()
    print('failed')
    print('')
    love.event.quit()
end

function scratch()
    base = Arc:new({ x = 200, y = 200, radius = 100, start_rads = 0, end_rads = 2 * math.pi})

    print('testing coincident circles...')
    if not base:intersectsArc(base) then fail() end

    print('testing touching circles...')
    if not base:new({x = 0}):intersectsArc(base) then fail() end

    print('testing intersecting circles...')
    if not base:new({x = 100}):intersectsArc(base) then fail() end

    print('testing disjoint circles...')
    if base:new({x = 1000}):intersectsArc(base) then fail() end

    lower_half = base:new({ end_rads = math.pi })
    print('testing coincident arcs...')
    if not lower_half:intersectsArc(lower_half) then fail() end

    print('testing touching arcs...')
    if not lower_half:new({x = 0}):intersectsArc(lower_half) then fail() end

    print('testing intersecting arcs...')
    if not lower_half:new({x = 100}):intersectsArc(lower_half) then fail() end

    print('testing disjoint arcs...')
    if lower_half:new({x = 1000}):intersectsArc(lower_half) then fail() end

    print('finished testing')
    print('')
    io.read()
end
