package device_motion;

import msignal.Signal;

class DeviceMotion
{
    private static var _instance: DeviceMotion = null;

    public var onAccelerometerEvent(default, null): Signal1<AccelerometerData>;

	private function new(): Void
    {
        onAccelerometerEvent = new Signal1<AccelerometerData>();
    }

    public static inline function instance(): DeviceMotion
	{
		if (_instance == null)
		{
			_instance = new DeviceMotion();
		}

		return _instance;
	}

    public function startAccelerometerInput(_, _)
    {}

    public function stopAccelerometerInput()
    {}
}
