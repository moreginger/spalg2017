require 'arc'

function scratch()
    a1 = Arc:new(
        {
            x = 100,
            y = 200,
            radius = 100,
            start_rads = 0,
            end_rads = math.pi
        }
    )
    a2 = Arc:new(
        {
            x = 250,
            y = 200,
            radius = 100,
            start_rads = 0,
            end_rads = 2 * math.pi
        }
    )

    a1:intersectsArc(a2)
    io.read()
end
