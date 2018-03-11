<div id="gitment"></div>
<link rel="stylesheet" href="https://imsun.github.io/gitment/style/default.css">
<script src="https://imsun.github.io/gitment/dist/gitment.browser.js"></script>
<script>
var gitment = new Gitment({
  // id: '页面 ID', // 可选。默认为 location.href
  owner: 'beginor',
  repo: 'beginor.github.io',
  oauth: {
    client_id: '38041aabf493656eafb8',
    client_secret: 'd9eee6be54d64b4c4b13c64c74c4401011904493',
  },
})
gitment.render('gitment')
</script>
