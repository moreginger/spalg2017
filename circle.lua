
function intersectAngles(c1, c2)

    r1  = c1.radius
    r2 = c2.radius
    cx = c1.x
    cy = c1.y
    Cx = c2.x
    Cy = c2.y
    -- if c1.radius < c2.radius then
    -- else
    --     r  = c2.radius
    --     R  = c1.radius
    --     Cx = c1.x
    --     Cy = c1.y
    --     cx = c2.x
    --     cy = c2.y
    -- end

    --  Compute the vector
    dx = cx - Cx
    dy = cy - Cy

    d = math.sqrt(dx * dx + dy * dy)

    eps = 0.00001

    if d < eps then
        if math.abs(r1 - r2) < eps then
            --  Same circle at same location - infinite solutions.
            return null
        end
    end

    -- No intersection. Either the small circle contained within
    -- big circle or circles are simply disjoint.
    gap = d - (r1 + r2)
    nested_gap = math.max(r1, r2) - (math.min(r1, r2) + d)

    if gap > eps or nested_gap > eps then
        return {}
    end

    angle = math.atan(dy / dx)

    --   // Single intersection (kissing circles)
    if math.abs(gap) < eps or math.abs(nested_gap) < eps then
        return { angle }
    end

    delta = math.acos((r1*r1-d*d-r2*r2)/(-2.0*d*r2))
    return { angle + delta, angle - delta }

end