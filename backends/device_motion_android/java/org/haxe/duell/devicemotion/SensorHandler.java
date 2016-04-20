package org.haxe.duell.devicemotion;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import org.haxe.duell.DuellActivity;
import org.haxe.duell.hxjni.HaxeObject;

/**
 * @author João Xavier <joao.xavier@studio49.co>
 * 20/04/16
 */
public final class SensorHandler implements SensorEventListener {

    private final Dispatcher dispatcher;

    private SensorManager sensorManager;
    private Sensor sensor;
    private final boolean enabled;

    public static SensorHandler initialize(final HaxeObject handler)
    {
        return new SensorHandler(handler);
    }

    private SensorHandler(final HaxeObject handler) {
        dispatcher = new Dispatcher(handler);

        DuellActivity activity = DuellActivity.getInstance();
        sensorManager = (SensorManager) activity.getSystemService(Context.SENSOR_SERVICE);
        sensor = sensorManager != null ? sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER) : null;

        enabled = sensor != null;
    }

    public void start(float frequencySeconds) {
        if (!enabled) {
            return;
        }

        int frequencyUs = (int) Math.floor(frequencySeconds * 1_000_000);
        sensorManager.registerListener(this, sensor, frequencyUs);
    }

    public void stop() {
        if (!enabled) {
            return;
        }

        sensorManager.unregisterListener(this);
    }

    @Override
    public void onSensorChanged(SensorEvent sensorEvent) {
        dispatcher.setValues(sensorEvent.values);
        DuellActivity.getInstance().queueOnHaxeThread(dispatcher);
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int i) {
        // what to do lol
    }

    static class Dispatcher implements Runnable {
        private final HaxeObject handler;
        private float[] values;

        public Dispatcher(HaxeObject handler) {
            this.handler = handler;
        }

        public void setValues(final float[] values) {
            this.values = values;
        }

        @Override
        public void run() {
            handler.call3("onAccelerometerInput", values[0], values[1], values[2]);
        }
    }
}
