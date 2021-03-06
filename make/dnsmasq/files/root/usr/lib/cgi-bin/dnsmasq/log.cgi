#!/bin/sh


. /usr/lib/libmodcgi.sh

. /mod/etc/conf/dnsmasq.cfg

script() {
	cat << \EOF
<script type="text/javascript">
	var log, fi;
	function add_option(value) {
		var option = document.createElement("option");
		option.value = value;
		option.appendChild(document.createTextNode(value));
		fi.select.appendChild(option);
	}
	function add_presets() {
		var ident = /^(\S+\s+){3}([^\s:[]+)/;
		var collect = new Array();
		var line = log.firstChild;
		while (line != null) {
			var text = line.firstChild.nodeValue;
			var result = ident.exec(text);
			if (result) {
				collect[result[2]] = 1;
			}
			line = line.nextSibling;
		}
		var options = new Array();
		for (var c in collect) {
			options.push(c);
		}
		options.sort();
		add_option("");
		for (var i in options) {
			add_option(options[i]);
		}
	}
	function filter(pattern) {
		var regexp = new RegExp(pattern, "i");
		var line = log.firstChild;
		while (line != null) {
			var style = line.style;
			style.display = regexp.test(line.firstChild.nodeValue) ? 'inline' : 'none';
			line = line.nextSibling;
		}
	}
	function grep(pattern) {
		fi.regexp.value = pattern;
		fi.onsubmit();
	}
	window.onload = function() {
		log = document.getElementById("log");
		fi = document.getElementById("filter");
		add_presets();
		fi.style.display = 'block';
		fi.onsubmit();
	}
</script>
EOF
}
filter_form() {
	cat << \EOF
<form id="filter" onsubmit="filter(this.regexp.value); return false;"
style="display: none">
	Filter:
	<select name="select" onchange="grep(this.value)" onkeyup="grep(this.value)"></select>
	<input type="text" name="regexp">
</form>
EOF
}

log_stream() {
	local title=$1
	echo "<h1>$title</h1>"
	filter_form
	echo -n '<pre id="log" class="log full"><span>'
	html | sed -r '2,$s#^#</span><span>#'
	echo '</span></pre>'
}
log_file() {
	log_stream "$1" < "$1"
}

script
log_file $DNSMASQ_LOG_FILE
