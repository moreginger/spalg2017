
-- Return intersect angles in radians where 0 = right, pi/2 = down etc.
-- Adapted from https://github.com/williamfiset/Algorithms/blob/master/Geometry/CircleCircleIntersectionPoints.js
function intersectAngles(c1, c2)

    r1 = c1.radius
    r2 = c2.radius

    --  Compute the vector
    dx = r1 >= r2 and c2.x - c1.x or c1.x - c2.x
    dy = r1 >= r2 and c2.y - c1.y or c1.y - c2.y

    d = math.sqrt(dx * dx + dy * dy)

    eps = 0.00001

    if d < eps and math.abs(r1 - r2) < eps then
        --  Same circle at same location - infinite solutions.
        return null
    end

    gap = d - (r1 + r2)
    nested_gap = math.max(r1, r2) - (math.min(r1, r2) + d)

    if gap > eps or nested_gap > eps then
        -- No intersection. Either the small circle contained within
        -- big circle or circles are simply disjoint.
        return {}
    end

    angle = math.atan2(dy, dx)
    -- print('base angle', angle)
    -- Distance at which the intersection points 'flip' onto the opposite side of the circle
    -- I'm sure there must be better math for this :S
    flip_d = math.abs(r1 - r2) < eps and 0 or math.sqrt(math.pow(math.max(r1, r2), 2) - math.pow(math.min(r1, r2) / 2, 2))
    c1_fudge = 0
    c2_fudge = 0
    if flip_d <= d then
        c1_fudge = r1 >= r2 and 0 or math.pi
        c2_fudge = r1 >= r2 and math.pi or 0
    end
    -- print('flip flop', d, flip_d, c1_fudge, c2_fudge)

    --   // Single intersection (kissing circles)
    c1_angle = angle + c1_fudge
    c2_angle = angle + c2_fudge
    if math.abs(gap) < eps or math.abs(nested_gap) < eps then
        return { { normalizeAngle(c1_angle), normalizeAngle(c2_angle) } }
    end

    r_small = math.min(r1, r2)
    r_big = math.max(r1, r2)
    delta_big = math.acos((r_small*r_small-d*d-r_big*r_big)/(-2.0*d*r_big))
    delta_small = math.asin(math.sin(delta_big) * r_big / r_small)

    if r1 >= r2 then
        c1_angle_1 = c1_angle + delta_big
        c2_angle_1 = c2_angle - delta_small
        c1_angle_2 = c1_angle - delta_big
        c2_angle_2 = c2_angle + delta_small
    else
        c1_angle_1 = c1_angle + delta_small
        c2_angle_1 = c2_angle - delta_big
        c1_angle_2 = c1_angle - delta_small
        c2_angle_2 = c2_angle + delta_big
    end

    return {
        { normalizeAngle(c1_angle_1), normalizeAngle(c2_angle_1) },
        { normalizeAngle(c1_angle_2), normalizeAngle(c2_angle_2) }
    }

end

function normalizeAngle(angle)
    return angle % (math.pi * 2)
end
