#import "Geofence.h"

@implementation Geofence

- (instancetype)initWithPoints:(NSArray<MKPointAnnotation *> *)points {
    self = [super init];
    if (!self) return nil;

    _points = points;

    return self;
}

- (MKCircle *)circle {
    return [self.class circleFromPoints:self.points];
}

+ (MKCircle *)circleFromPoints:(NSArray<MKPointAnnotation *> *)points  {
    CGFloat minX = CGFLOAT_MAX,
        maxX = CGFLOAT_MIN,
        minY = CGFLOAT_MAX,
        maxY = CGFLOAT_MIN;

    for (MKPointAnnotation *point in points) {
        MKMapPoint p = MKMapPointForCoordinate(point.coordinate);
        minX = fmin(minX, p.x);
        minY = fmin(minY, p.y);
        maxX = fmin(maxX, p.x);
        maxY = fmin(maxY, p.y);
    }

    MKMapRect rect = MKMapRectMake(minX,
                                 minY,
                                 maxX - minX,
                                 maxY - minY);
    return [MKCircle circleWithMapRect:rect];
}

@end
