<script type="text/javascript" src="/assets/syntaxhighlighter/scripts/shCore.js"></script>
<script type="text/javascript" src="/assets/syntaxhighlighter/scripts/shAutoloader.js"></script>
<script type="text/javascript">
$(document).ready(function() {

	$('pre code').each(function(idx, el) {
		el.parentElement.className = 'brush: ' + (el.className || 'plain') + ';';
		el.parentElement.innerHTML = el.innerHTML;
	});

	function path() {
		var args = arguments, result = [];
		for(var i = 0; i < args.length; i++) {
			result.push(args[i].replace('@', '/assets/syntaxhighlighter/scripts/'));
		}
		return result
	};

	SyntaxHighlighter.autoloader.apply(null, path(
		'actionscript3 as3      @shBrushAS3.js',
		'applescript            @shBrushAppleScript.js',
		'bash shell             @shBrushBash.js',
		'c# c-sharp csharp      @shBrushCSharp.js',
		'coldfusion cf          @shBrushColdFusion.js',
		'cpp c                  @shBrushCpp.js',
		'css                    @shBrushCss.js',
		'delphi pascal          @shBrushDelphi.js',
		'diff patch pas         @shBrushDiff.js',
		'erl erlang             @shBrushErlang.js',
		'groovy                 @shBrushGroovy.js',
		'js jscript javascript  @shBrushJScript.js',
		'java                   @shBrushJava.js',
		'jfx javafx             @shBrushJavaFX.js',
		'perl pl                @shBrushPerl.js',
		'php                    @shBrushPhp.js',
		'text plain             @shBrushPlain.js',
		'ps                     @shBrushPowerShell.js',
		'py python              @shBrushPython.js',
		'ruby rails ror rb      @shBrushRuby.js',
		'sass scss              @shBrushSass.js',
		'scala                  @shBrushScala.js',
		'sql                    @shBrushSql.js',
		'vb vbnet               @shBrushVb.js',
		'xml xhtml xslt html    @shBrushXml.js'
	));

	SyntaxHighlighter.all();
});
</script>