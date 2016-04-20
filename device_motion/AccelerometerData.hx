/*
 * Copyright (c) 2003-2016, GameDuell GmbH
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

class AccelerometerData
{
    public var x (default, null): Float;
    public var y (default, null): Float;
    public var z (default, null): Float;

    public var xFiltered (default, null): Float;
    public var yFiltered (default, null): Float;
    public var zFiltered (default, null): Float;

    private var filterValue: Float;

    public function new(filterValue: Float): Void
    {
        this.filterValue = filterValue;

        x = 0;
        y = 0;
        z = 0;

        xFiltered = 0;
        yFiltered = 0;
        zFiltered = 0;
    }

    /**
        The expected values `xRaw`, `yRaw` and `zRaw` are in g-forces (https://en.wikipedia.org/wiki/G-force).
     */
    public function updateData(xRaw: Float, yRaw: Float, zRaw: Float): Void
    {
        x = xRaw;
        y = yRaw;
        z = zRaw;

        // Use a basic low-pass filter to only keep the gravity in the accelerometer values
        var factor: Float = filterValue;
        var inverseFactor: Float = (1.0 - factor);
        xFiltered = x * factor + xFiltered * inverseFactor;
        yFiltered = y * factor + yFiltered * inverseFactor;
        zFiltered = z * factor + zFiltered * inverseFactor;

        xFiltered = Math.min(Math.max(xFiltered, -1.0), 1.0);
        yFiltered = Math.min(Math.max(yFiltered, -1.0), 1.0);
        zFiltered = Math.min(Math.max(zFiltered, -1.0), 1.0);
    }
}