function videoSizeChanged(vw, vh) {
        if (Stage.displayState == "fullScreen") {
            super.videoSizeChanged(vw, vh);
            return;
        }
		
        var bgW = _background._width;
        var bgH = _background._height;
        _maxAdHeight = _background._height;
        vw = vw / vh * _maxAdHeight;
        vh = _maxAdHeight;
		
        if (vw <= bgW && vh <= bgH) {
            _video._width = vw;
            _video._height = vh;
        } else if (vw > bgW && vh <= bgH) {
            vh = bgW * vh / vw;
            vw = bgW;
            _video._width = vw;
            _video._height = vh;
        } else if (vw <= bgW && vh > bgH) {
            vw = bgH * vw / vh;
            vh = bgH;
            _video._width = vw;
            _video._height = vh;
        } else if (vw / vh >= bgW / bgH) {
            _video._width = bgW;
            _video._height = _video._width * vh / vw;
        } else {
            _video._height = bgH;
            _video._width = _video._height * vw / vh;
        }
    }