import QtQuick 1.1
import org.LC.common 1.0
import org.LC.File 1.0
import "CpuLoadHistory.js" as CpuLoadHistory

Item
{
	id: rootRect

	implicitWidth: parent.quarkBaseSize
	implicitHeight: parent.quarkBaseSize

	property int busy: 0
	property int work: 0

	File
	{
		id: procStatFile
		source: "/proc/stat"
		openMode: FileProxy.ReadOnly
		onError: console.log ("err", msg)
	}

	Timer
	{
		id: updateTimer
		interval: UpdateCpuLoadInterval * 1000
		repeat: true
		running: true
		triggeredOnStart: true
		onTriggered:
		{
			CpuLoadHistory.addCpuLoadValue (getCPULoad ("cpu"))
			var history = CpuLoadHistory.getCpuLoadHistory ()
			cpuLoadImage.points = history;
			cpuLoadText.text = history [history.length - 1].y + "%"
		}
	}


	Plot
	{
		id: cpuLoadImage
		height: rootRect.implicitHeight
		width: rootRect.implicitWidth

		points: CpuLoadHistory.getCpuLoadHistory ()

		Text
		{
			id: cpuLoadText
			anchors.centerIn: parent
			font.pixelSize: parent.height / 4
			color: colorProxy.color_Panel_TextColor
		}
	}

	function getCPULoad (cpuName)
	{
		var result = 0;
		if (procStatFile.openMode == FileProxy.NotOpen)
			return result;

		var lines = procStatFile.ReadAll ().split ("\n");
		procStatFile.Seek (0);

		var newBusy = 0;
		var newWork = 0;
		for (var i = 0; i < lines.length; ++i)
		{
			var string = lines [i];
			if (!string.indexOf (cpuName + " "))
			{
				var columns = string.split (" ");
				for (var j = 2; j < 5; ++j)
					newBusy = newBusy + parseInt (columns [j])

				newWork = newBusy + parseInt (columns [5])

				result = (newBusy - busy) / (newWork - work) * 100;

				work = newWork
				busy = newBusy

				return Math.round (result * 10) / 10;
			}
		}
		return result;
	}
}
