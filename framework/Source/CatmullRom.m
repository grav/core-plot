//
// Created by Mikkel Gravgaard on 27/11/14.
// From this post: http://stackoverflow.com/questions/9489736/catmull-rom-curve-with-no-cusps-and-no-self-intersections
//

#import "CatmullRom.h"


@implementation CatmullRom {

}

#pragma mark - Catmull

+(NSMutableArray *)interpolate:(NSArray *)coordinates withPointsPerSegment:(NSInteger)pointsPerSegment andType:(CatmullRomType)curveType {

    NSMutableArray *vertices = [[NSMutableArray alloc] initWithArray:coordinates copyItems:YES];

    if (pointsPerSegment < 3)
        return vertices;

    //start point
    CGPoint pt1 = [vertices[0] CGPointValue];
    CGPoint pt2 = [vertices[1] CGPointValue];

    double dx = pt2.x - pt1.x;
    double dy = pt2.y - pt1.y;

    double x1 = pt1.x - dx;
    double y1 = pt1.y - dy;

    CGPoint start = CGPointMake(x1*.5, y1);

    //end point
    pt2 = [vertices[vertices.count-1] CGPointValue];
    pt1 = [vertices[vertices.count-2] CGPointValue];

    dx = pt2.x - pt1.x;
    dy = pt2.y - pt1.y;

    x1 = pt2.x + dx;
    y1 = pt2.y + dy;

    CGPoint end = CGPointMake(x1, y1);

    [vertices insertObject:[NSValue valueWithCGPoint:start] atIndex:0];
    [vertices addObject:[NSValue valueWithCGPoint:end]];

    NSMutableArray *result = [NSMutableArray array];

    for (int i = 0; i < vertices.count - 3; i++) {
        NSMutableArray *points = [self interpolate:vertices forIndex:i withPointsPerSegment:pointsPerSegment andType:curveType];

        if ([points count] > 0)
            [points removeObjectAtIndex:0];

        [result addObjectsFromArray:points];
    }

    return result;
}

+(double)interpolate:(double*)p  time:(double*)time t:(double) t {
    double L01 = p[0] * (time[1] - t) / (time[1] - time[0]) + p[1] * (t - time[0]) / (time[1] - time[0]);
    double L12 = p[1] * (time[2] - t) / (time[2] - time[1]) + p[2] * (t - time[1]) / (time[2] - time[1]);
    double L23 = p[2] * (time[3] - t) / (time[3] - time[2]) + p[3] * (t - time[2]) / (time[3] - time[2]);
    double L012 = L01 * (time[2] - t) / (time[2] - time[0]) + L12 * (t - time[0]) / (time[2] - time[0]);
    double L123 = L12 * (time[3] - t) / (time[3] - time[1]) + L23 * (t - time[1]) / (time[3] - time[1]);
    double C12 = L012 * (time[2] - t) / (time[2] - time[1]) + L123 * (t - time[1]) / (time[2] - time[1]);
    return C12;
}

+(NSMutableArray*)interpolate:(NSArray *)points forIndex:(NSInteger)index withPointsPerSegment:(NSInteger)pointsPerSegment andType:(CatmullRomType)curveType {
    NSMutableArray *result = [NSMutableArray array];

    double x[4];
    double y[4];
    double time[4];

    for (int i=0; i < 4; i++) {
        x[i] = [points[index+i] CGPointValue].x;
        y[i] = [points[index+i] CGPointValue].y;
        time[i] = i;
    }

    double tstart = 1;
    double tend = 2;

    if (curveType != CatmullRomTypeUniform) {
        double total = 0;

        for (int i=1; i < 4; i++) {
            double dx = x[i] - x[i-1];
            double dy = y[i] - y[i-1];

            if (curveType == CatmullRomTypeCentripetal) {
                total += pow(dx * dx + dy * dy, 0.25);
            }
            else {
                total += pow(dx * dx + dy * dy, 0.5); //sqrt
            }
            time[i] = total;
        }
        tstart = time[1];
        tend = time[2];
    }

    int segments = pointsPerSegment - 1;

    [result addObject:points[index+1]];

    for (int i =1; i < segments; i++) {
        double xi = [self interpolate:x time:time t:tstart + (i * (tend - tstart)) / segments];
        double yi = [self interpolate:y time:time t:tstart + (i * (tend - tstart)) / segments];
        [result addObject:[NSValue valueWithCGPoint:CGPointMake(xi, yi)]];
    }
    [result addObject:points[index+2]];

    return result;
}


@end