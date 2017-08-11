
function intersectAngles(c1, c2)

    if c1.radius < c2.radius then
        r  = c1.radius
        R = c2.radius
        cx = c1.x
        cy = c1.y
        Cx = c2.x
        Cy = c2.y
    else
        r  = c2.radius
        R  = c1.radius
        Cx = c1.x
        Cy = c1.y
        cx = c2.x
        cy = c2.y
    end

    --   // Compute the vector <dx, dy>
    dx = cx - Cx
    dy = cy - Cy

    --   // Find the distance between two points.
    d = math.sqrt( dx*dx + dy*dy )

    --   // There are an infinite number of solutions
    --   // Seems appropriate to also return null
    eps = 0.00001
    if d < eps and math.abs(R-r) < eps then
        return null
    end

    --   // No intersection (circles centered at the
    --   // same place with different size)
    if d < eps then
        return {}
    end

    -- // No intersection. Either the small circle contained within 
    -- // big circle or circles are simply disjoint.
    if d + r < R or R + r < d then
        return {}
    end

    -- x = (dx / d) * R + Cx
    -- y = (dy / d) * R + Cy
    A = math.atan(dx / dy)

    --   // Single intersection (kissing circles)
    if math.abs((R+r)-d) < eps or math.abs(R-(r+d)) < eps then
        return { A }
    end

    angle = math.acos((r*r-d*d-R*R)/(-2.0*d*R))
    return { A + angle, A - angle }

end