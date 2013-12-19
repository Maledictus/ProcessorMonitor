var cpuLoad = new Array

function getCpuLoadHistory ()
{
	return cpuLoad;
}

function addCpuLoadValue (value)
{
	cpuLoad.push (Qt.point (cpuLoad.length, value))
	if (cpuLoad.length > 100)
		cpuLoad.shift ();
}
