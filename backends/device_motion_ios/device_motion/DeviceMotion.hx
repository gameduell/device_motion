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

package device_motion;

import cpp.Lib;
import msignal.Signal;


class DeviceMotion
{
    private static var device_motion_start_accelerometer_input: Dynamic = null;
    private static var device_motion_stop_accelerometer_input: Dynamic = null;

    private static var _instance: DeviceMotion = null;

    public var onAccelerometerEvent(default, null): Signal1<AccelerometerData>;

    private var data: AccelerometerData;

	private function new(): Void
    {
        data = null;
        onAccelerometerEvent = new Signal1<AccelerometerData>();
    }

    static public inline function instance(): DeviceMotion
	{
		if (_instance == null)
		{
            // lazily initialize the native lib
            device_motion_start_accelerometer_input = Lib.load ("device_motion", "device_motion_start_accelerometer_input", 2);
            device_motion_stop_accelerometer_input = Lib.load ("device_motion", "device_motion_stop_accelerometer_input", 0);

			_instance = new DeviceMotion();
		}

		return _instance;
	}

    public function startAccelerometerInput(filterValue: Float = 0.1, frequency: Float = (1.0/60.0)): Void
    {
        if (data == null)
        {
            data = new AccelerometerData(filterValue);
        }

        device_motion_start_accelerometer_input(frequency, onAccelerometerInput);
    }

    public function stopAccelerometerInput(): Void
    {
        device_motion_stop_accelerometer_input();
        onAccelerometerEvent.removeAll();
        data = null;
    }

    private function onAccelerometerInput(x: Float, y: Float, z: Float): Void
    {
        data.updateData(x, y, z);

        onAccelerometerEvent.dispatch(data);
    }
}
