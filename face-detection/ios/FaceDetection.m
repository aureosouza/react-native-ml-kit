#import "FaceDetection.h"
#import <Vision/Vision.h>

@implementation FaceDetection

RCT_EXPORT_MODULE()

- (NSDictionary*)frameToDict: (CGRect)frame {
    return @{
        @"width": @(frame.size.width),
        @"height": @(frame.size.height),
        @"left": @(frame.origin.x),
        @"top": @(frame.origin.y)
    };
}

- (NSDictionary*)pointToDict: (CGPoint)point {
    return @{
        @"x": @(point.x),
        @"y": @(point.y),
    };
}

- (NSDictionary*)faceToDict: (VNFaceObservation*)face {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[self frameToDict:face.boundingBox] forKey:@"frame"];
    
    if (face.hasFaceAngle) {
        [dict setObject:@(face.faceAngle) forKey:@"faceAngle"];
    }
    
    if (face.landmarks) {
        NSMutableDictionary *landmarks = [NSMutableDictionary dictionary];
        
        VNFaceLandmarkRegion2D *leftEye = face.landmarks.leftEye;
        if (leftEye) {
            NSMutableArray *points = [NSMutableArray array];
            for (VNFaceLandmarkPoint *point in leftEye.points) {
                [points addObject:[self pointToDict:point.point]];
            }
            [landmarks setObject:points forKey:@"leftEye"];
        }
        
        VNFaceLandmarkRegion2D *rightEye = face.landmarks.rightEye;
        if (rightEye) {
            NSMutableArray *points = [NSMutableArray array];
            for (VNFaceLandmarkPoint *point in rightEye.points) {
                [points addObject:[self pointToDict:point.point]];
            }
            [landmarks setObject:points forKey:@"rightEye"];
        }
        
        VNFaceLandmarkRegion2D *nose = face.landmarks.nose;
        if (nose) {
            NSMutableArray *points = [NSMutableArray array];
            for (VNFaceLandmarkPoint *point in nose.points) {
                [points addObject:[self pointToDict:point.point]];
            }
            [landmarks setObject:points forKey:@"nose"];
        }
        
        [dict setObject:landmarks forKey:@"landmarks"];
    }
    
    return dict;
}

RCT_EXPORT_METHOD(detect: (nonnull NSString*)url
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSURL *_url = [NSURL URLWithString:url];
    NSData *imageData = [NSData dataWithContentsOfURL:_url];
    UIImage *image = [UIImage imageWithData:imageData];
    
    VNImageRequestHandler *requestHandler = [[VNImageRequestHandler alloc] initWithCGImage:image.CGImage options:@{}];
    
    VNDetectFaceRectanglesRequest *request = [[VNDetectFaceRectanglesRequest alloc] initWithCompletionHandler:^(VNRequest *request, NSError *error) {
        if (error != nil) {
            reject(@"Face Detection", @"Face detection failed", error);
            return;
        }
        
        NSMutableArray *result = [NSMutableArray array];
        for (VNFaceObservation *face in request.results) {
            [result addObject:[self faceToDict:face]];
        }
        resolve(result);
    }];
    
    NSError *error;
    BOOL success = [requestHandler performRequests:@[request] error:&error];
    if (!success) {
        reject(@"Face Detection", @"Face detection failed", error);
    }
}

@end
