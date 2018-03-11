<div id="gitment"></div>
<link rel="stylesheet" href="https://imsun.github.io/gitment/style/default.css">
<script src="https://imsun.github.io/gitment/dist/gitment.browser.js"></script>
<script>
var gitment = new Gitment({
  // id: '页面 ID', // 可选。默认为 location.href
  owner: 'beginor',
  repo: 'beginor.github.io',
  oauth: {
    client_id: '3923f5bda4f4ec12beed',
    client_secret: '3ce07e16135f6c2ccc6d365d14d7d14d4e2cad2b',
  },
})
gitment.render('gitment')
</script>
