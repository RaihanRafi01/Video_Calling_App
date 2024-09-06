import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import us.zoom.sdk.ZoomVideoSDK
import us.zoom.sdk.ZoomVideoSDKInitParams
import us.zoom.sdk.ZoomVideoSDKInitSettings
import us.zoom.sdk.ZoomVideoSDKError
import us.zoom.sdk.ZoomVideoSDKSession

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.video_calling_app/zoom"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initializeZoomSdk" -> initializeZoomSdk(result)
                "joinMeeting" -> joinMeeting(call.arguments as Map<String, String>, result)
                "startMeeting" -> startMeeting(call.arguments as Map<String, String>, result)
                else -> result.notImplemented()
            }
        }
    }

    private fun initializeZoomSdk(result: MethodChannel.Result) {
        val initParams = ZoomVideoSDKInitParams().apply {
            appKey = "4EWtf96CozmNxQwZu5LWO3gvojDqCJAq963S"
            appSecret = "2GEaEgblthLBOYcKjz6rbXswWsQgYMOyHrYu"
        }
        val initSettings = ZoomVideoSDKInitSettings().apply {
            isLogEnabled = true
        }

        ZoomVideoSDK.getInstance().initialize(this, initParams, initSettings) { error ->
            if (error == ZoomVideoSDKError.SDKERR_SUCCESS) {
                result.success("Zoom SDK initialized successfully")
            } else {
                result.error("ERROR", "Failed to initialize Zoom SDK", null)
            }
        }
    }

    private fun joinMeeting(arguments: Map<String, String>, result: MethodChannel.Result) {
        val sessionName = arguments["sessionName"] ?: return result.error("ERROR", "Missing sessionName", null)
        val sessionPassword = arguments["sessionPassword"] ?: return result.error("ERROR", "Missing sessionPassword", null)

        val session = ZoomVideoSDKSession().apply {
            sessionName = sessionName
            sessionPassword = sessionPassword
        }

        ZoomVideoSDK.getInstance().joinSession(session) { error ->
            if (error == ZoomVideoSDKError.SDKERR_SUCCESS) {
                result.success("Joined meeting successfully")
            } else {
                result.error("ERROR", "Failed to join meeting", null)
            }
        }
    }

    private fun startMeeting(arguments: Map<String, String>, result: MethodChannel.Result) {
        val sessionName = arguments["sessionName"] ?: return result.error("ERROR", "Missing sessionName", null)

        val session = ZoomVideoSDKSession().apply {
            sessionName = sessionName
        }

        ZoomVideoSDK.getInstance().startSession(session) { error ->
            if (error == ZoomVideoSDKError.SDKERR_SUCCESS) {
                result.success("Started meeting successfully")
            } else {
                result.error("ERROR", "Failed to start meeting", null)
            }
        }
    }
}
