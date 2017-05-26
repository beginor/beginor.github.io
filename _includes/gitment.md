<div id="gitment"></div>
<link rel="stylesheet" href="https://imsun.github.io/gitment/style/default.css">
<script src="https://imsun.github.io/gitment/dist/gitment.browser.js"></script>
<script>
var gitment = new Gitment({
  // id: '页面 ID', // 可选。默认为 location.href
  owner: 'beginor',
  repo: 'beginor.github.io',
  oauth: {
    client_id: '194877e219e32f2200d8',
    client_secret: 'e1b62c4e0a86a5fdd896a98fb943dcb882f851a2',
  },
})
gitment.render('gitment')
</script>
