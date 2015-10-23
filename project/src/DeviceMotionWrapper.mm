/*
 * Copyright (c) 2003-2015, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <CoreMotion/CoreMotion.h>

#import "DeviceMotionWrapper.h"


@interface DeviceMotionWrapper ()
{
    AutoGCRoot* _accelerometerCallback;
}

@property (nonatomic, readwrite, strong) CMMotionManager* motionManager;

@end


@implementation DeviceMotionWrapper

- (void) startAccelerometerInputWithFrequency:(value)frequency callback:(value)callback
{
    if (!self.motionManager)
    {
        self.motionManager = [[[CMMotionManager alloc] init] autorelease];
        self.motionManager.accelerometerUpdateInterval = val_float(frequency);
    }

    _accelerometerCallback = new AutoGCRoot(callback);

    if ([self.motionManager isAccelerometerAvailable])
    {
        NSOperationQueue* queue = [[NSOperationQueue alloc] init];
        [self.motionManager
         startAccelerometerUpdatesToQueue:queue
         withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
         {
            if (_accelerometerCallback == NULL)
            {
                return;
            }

            dispatch_async(dispatch_get_main_queue(), ^
            {
                if (_accelerometerCallback == NULL)
                {
                    return;
                }
                
                val_call3(_accelerometerCallback->get(), 
                    alloc_float(accelerometerData.acceleration.x), 
                    alloc_float(accelerometerData.acceleration.y), 
                    alloc_float(accelerometerData.acceleration.z));

                // NSLog(@"x %.2f y %.2f z %.2f", accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z);
            });
        }];
    }
}

- (void) stopAccelerometerInput
{
    [self.motionManager stopAccelerometerUpdates];

    delete _accelerometerCallback;
    _accelerometerCallback = NULL;
}

- (void) dealloc
{
    delete _accelerometerCallback;

    [super dealloc];
}

@end
