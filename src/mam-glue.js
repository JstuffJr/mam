var _pjs=this;

//	'//googledrive.com/host/0BzcEQMWUa0znRE1wQU9KUGR2R2s/mam/mam-pre2-min.js';
var mamLoad = function(config) {
	mamLoad.f = true;
	
	(function(){
		var root = this;
		var fn = function() {
			if (mamLoad.f) {
				if (! root._mamScript) {
					root.$.ajaxSetup({ cache: true });
					root._mamScript = root.$.getScript('//googledrive.com/host/0BzcEQMWUa0znRE1wQU9KUGR2R2s/mam/mam-pre3-min.js');
				}

				root._mamScript.done(function() {
					if (! root._mam)
						root._mam = new (root.MAM)(config, _pjs);
					root._mam.run();
				});
			}
		};
		root.setTimeout(fn, 0);
	})();
};
