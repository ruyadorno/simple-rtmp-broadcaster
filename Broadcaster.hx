import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;

import flash.media.Camera;
import flash.media.Microphone;
import flash.media.Video;
import flash.media.H264Level;
import flash.media.H264Profile;
import flash.media.H264VideoStreamSettings;

import flash.events.MouseEvent;
import flash.events.NetStatusEvent;

import flash.net.NetConnection;
import flash.net.NetStream;

class Broadcaster {

	private var isBroadcasting:Bool;

	private var camera:Camera;
	private var microphone:Microphone;
	private var video:Video;
	private var videoContainer:Sprite;
	private var recButton:Sprite;

	private var netConnection:NetConnection;
	private var netStream:NetStream;
	private var streamType:String;

	public function new():Void {
		this.setupConnection();
		this.setupStage();
	}

	private function getRecShape(isBroadcasting):Shape {
		var circle:Shape = new Shape();
		var fill:UInt = isBroadcasting ? 0x000000 : 0x990000;
		var line:UInt = isBroadcasting ? 3 : 0;
		circle.graphics.clear();
		circle.graphics.lineStyle(line, 0xFFFFFF);
		circle.graphics.beginFill(fill);
		circle.graphics.drawCircle(0, 0, 30);
		circle.graphics.endFill();
		return circle;
	}

	private function onRecButtonClick(event:MouseEvent):Void {
		isBroadcasting = !isBroadcasting;
		if (isBroadcasting) {
			startBroadcast();
		} else {
			stopBroadcast();
		}
		recButton.removeChildAt(0);
		recButton.addChildAt(getRecShape(isBroadcasting), 0);
	}

	private function onStatus(event:NetStatusEvent):Void {
		trace(event.info.code);
		if (event.info.code == "NetConnection.Connect.Closed") {
			stopBroadcast();
		} else if (event.info.code == "NetConnection.Connect.Success") {
			startVideoPublish();
		} else if (event.info.code == "NetStream.Publish.BadName") {
			stopVideoPublish();
		} else if (event.info.code == "NetStream.Publish.Start") {
			trace("Success");
		}
	}

	private function getVideoSettings():H264VideoStreamSettings {
		var h264settings:H264VideoStreamSettings = new H264VideoStreamSettings();
		h264settings.setProfileLevel(H264Profile.BASELINE, H264Level.LEVEL_3_1);

		// TODO may be optional
		if (netStream != null) {
			netStream.bufferTime=3;
		}

		return h264settings;
	}

	private function configMicrophone():Void {
		microphone.codec = flash.media.SoundCodec.SPEEX;
		microphone.framesPerPacket = 2;
		microphone.noiseSuppressionLevel = 0;
		microphone.setUseEchoSuppression(false);
		microphone.gain = 50;
		microphone.enableVAD = false;
		microphone.setSilenceLevel(0);
		microphone.encodeQuality = 10;
	}

	private function startVideoPublish():Void {
		this.configMicrophone();

		streamType = "record";
		netStream = new NetStream(netConnection);
		netStream.bufferTime = 0;
		netStream.client = this;
		netStream.attachCamera(camera);
		netStream.attachAudio(microphone);
		netStream.addEventListener(NetStatusEvent.NET_STATUS, onStatus, false);
		netStream.videoStreamSettings = getVideoSettings();
		netStream.publish(flash.Lib.current.loaderInfo.parameters.streamname, "record");
		trace("Publishing");
	}

	private function stopVideoPublish():Void {
		stopBroadcast();
		recButton.removeChildAt(0);
		recButton.addChildAt(getRecShape(isBroadcasting), 0);
	}

	public function startBroadcast():Void {
		netConnection = new NetConnection();
		netConnection.client = this;
		netConnection.addEventListener(NetStatusEvent.NET_STATUS, onStatus, false, 0, true);
		netConnection.connect("rtmp://" + flash.Lib.current.loaderInfo.parameters.host + "/" + flash.Lib.current.loaderInfo.parameters.context);
	}

	public function stopBroadcast():Void {
		if(netStream != null) {
			netStream.removeEventListener(NetStatusEvent.NET_STATUS, onStatus, false);
			netStream.close();
		}
		if (netConnection != null) {
			netConnection.removeEventListener(NetStatusEvent.NET_STATUS, onStatus, false);
			netConnection.close();
		}
		netStream = null;
		netConnection = null;
	}

	public function setupConnection():Void {
	}

	public function setupStage():Void {
		// camera
		camera = Camera.getCamera();
		camera.setMode(600, 600, 15);
		camera.setQuality(100 * 1000, 85);
		camera.setKeyFrameInterval(45);

		// mic
		microphone = Microphone.getMicrophone();

		// video
		video = new Video(300, 300);
		video.attachCamera(camera);
		video.smoothing = false;
		video.deblocking = 1;
		video.scaleX = -1;
		video.x = 300;

		// container
		videoContainer = new Sprite();
		videoContainer.addChild(video);

		// rec button
		recButton = new Sprite();
		recButton.addChildAt(getRecShape(false), 0);
		recButton.x = 400;
		recButton.y = 150;
		recButton.mouseChildren = false;
		recButton.buttonMode = true;
		recButton.useHandCursor = true;
		recButton.addEventListener(MouseEvent.CLICK, onRecButtonClick);

		// stage
		flash.Lib.current.addChildAt(videoContainer, 0);
		flash.Lib.current.addChildAt(recButton, 1);

		trace("UID: " + flash.Lib.current.loaderInfo.parameters.streamname);
		trace("Host: " + flash.Lib.current.loaderInfo.parameters.host);
		trace("Context: " + flash.Lib.current.loaderInfo.parameters.context);
	}
}

