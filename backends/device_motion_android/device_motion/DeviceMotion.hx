package device_motion;

import duellkit.DuellKit;
import hxjni.JNI;
import msignal.Signal;

class DeviceMotion
{
    private static inline var GRAVITATIONAL_PULL_ON_EARTH: Float = 9.81;

    private static var initializeNative: Dynamic = null;
    private static var startNative: Dynamic = null;
    private static var stopNative: Dynamic = null;

    private static var _instance: DeviceMotion = null;

    public var onAccelerometerEvent(default, null): Signal1<AccelerometerData>;

    private var javaObj: Dynamic;
    private var data: AccelerometerData;

    private var active: Bool;
    private var wasActive: Bool;
    private var lastFilterValue: Float;
    private var lastFrequency: Float;

	private function new(): Void
    {
        javaObj = initializeNative(this);
        data = null;
        active = wasActive = false;
        lastFilterValue = lastFrequency = 0.0;
        onAccelerometerEvent = new Signal1<AccelerometerData>();

        DuellKit.instance().onApplicationWillEnterBackground.add(onWillEnterBackground);
        DuellKit.instance().onApplicationWillEnterForeground.add(onWillEnterForeground);
    }

    static public inline function instance(): DeviceMotion
	{
		if (_instance == null)
		{
            initializeNative = JNI.createStaticMethod("org/haxe/duell/devicemotion/SensorHandler",
                    "initialize", "(Lorg/haxe/duell/hxjni/HaxeObject;)Lorg/haxe/duell/devicemotion/SensorHandler;");
            startNative = JNI.createMemberMethod("org/haxe/duell/devicemotion/SensorHandler", "start", "(F)V");
            stopNative = JNI.createMemberMethod("org/haxe/duell/devicemotion/SensorHandler", "stop", "()V");

			_instance = new DeviceMotion();
		}

		return _instance;
	}

    public function startAccelerometerInput(filterValue: Float = 0.1, frequency: Float = (1.0/60.0)): Void
    {
        lastFilterValue = filterValue;
        lastFrequency = frequency;

        if (data == null)
        {
            data = new AccelerometerData(filterValue);
        }

        active = true;
        startNative(javaObj, frequency);
    }

    public function stopAccelerometerInput(): Void
    {
        active = false;
        stopNative(javaObj);
        onAccelerometerEvent.removeAll();
        data = null;
    }

    @:keep
    private function onAccelerometerInput(x: Float, y: Float, z: Float): Void
    {
        if (active)
        {
            // values from Android accelerometer come in m/s2, updateData expects values in g-forces
            data.updateData(x / GRAVITATIONAL_PULL_ON_EARTH, y / GRAVITATIONAL_PULL_ON_EARTH, z / GRAVITATIONAL_PULL_ON_EARTH);

            onAccelerometerEvent.dispatch(data);
        }
    }

    private function onWillEnterBackground()
    {
        wasActive = active;

        if (wasActive)
        {
            stopAccelerometerInput();
        }
    }

    private function onWillEnterForeground()
    {
        if (wasActive)
        {
            startAccelerometerInput(lastFilterValue, lastFrequency);
        }
    }
}
