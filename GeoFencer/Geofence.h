@import MapKit;
#import <Mantle/Mantle.h>

@interface Geofence : MTLModel

- (instancetype)initWithPoints:(NSArray<MKPointAnnotation *> *)points;

@property (readonly, nonatomic, strong) NSArray<MKPointAnnotation *> *points;
@property (readonly) MKCircle *circle;

+ (MKCircle *)circleFromPoints:(NSArray<MKPointAnnotation *> *)points;

@end