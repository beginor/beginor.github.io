<div id="gitment"></div>
<link rel="stylesheet" href="https://imsun.github.io/gitment/style/default.css">
<script src="https://imsun.github.io/gitment/dist/gitment.browser.js"></script>
<script>
var page_date = '{{ page.date }}';
var id = window.location.href;
if (page_date > '2018-04-31 00:00:00 +0000') {  // 兼容以前的评论
  id = page_date;
}
var gitment = new Gitment({
  id: id, // 可选。默认为 location.href
  owner: 'beginor',
  repo: 'beginor.github.io',
  oauth: {
    client_id: '38041aabf493656eafb8',
    client_secret: 'd9eee6be54d64b4c4b13c64c74c4401011904493',
  },
})
gitment.render('gitment');
</script>
