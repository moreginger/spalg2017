
-- Return intersect angles in radians where 0 = right, pi/2 = down etc.
function intersectAngles(c1, c2)

    r1 = c1.radius
    r2 = c2.radius

    --  Compute the vector
    dx = c2.x - c1.x
    dy = c2.y - c1.y

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

    angle = math.abs(dx) > 0 and math.atan(math.abs(dy) / math.abs(dx)) or math.pi / 2
    angle = dx >= 0 and angle or math.pi - angle
    angle = dy >= 0 and angle or math.pi * 2 - angle

    --   // Single intersection (kissing circles)
    if math.abs(gap) < eps or math.abs(nested_gap) < eps then
        return { { normalizeAngle(angle), normalizeAngle(angle + math.pi) } }
    end

    delta1 = math.acos((r1*r1-d*d-r2*r2)/(-2.0*d*r2))
    delta2 = math.acos((r2*r2-d*d-r1*r1)/(-2.0*d*r1))
    return {
        { normalizeAngle(angle + delta1), normalizeAngle(angle + math.pi - delta2) },
        { normalizeAngle(angle - delta1), normalizeAngle(angle + math.pi + delta2) }
    }

end

function normalizeAngle(angle)
    return angle % (math.pi * 2)
end
