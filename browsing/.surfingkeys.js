const hintsCss =
      "font-size: 10pt; font-family: BreezeSans, Hermit, monospace; border: 0px; color:#2c363c; background: initial; background-color: #f0edec;";

api.Hints.style(hintsCss);
api.Hints.style(hintsCss, "text");
settings.theme = `
.sk_theme {
  font-family:  BreezeSans, Hermit, monospace;
  font-size: 10pt;
  background: #f0edec;
  color: #2c363c;
}
.sk_theme tbody {
  color: #f0edec;
}
.sk_theme input {
  color: #2c363c;
}
.sk_theme .url {
  color: #1d5573;
}
.sk_theme .annotation {
  color: #2c363c;
}
.sk_theme .omnibar_highlight {
  color: #88507d;
}
.sk_theme #sk_omnibarSearchResult ul li:nth-child(odd) {
  background: #f0edec;
}
.sk_theme #sk_omnibarSearchResult ul li.focused {
  background: #cbd9e3;
}
#sk_status,
#sk_find {
  font-size: 10pt;
}
`;

// set default back/forward, prev/next tab movements to vimium style
api.map('K', 'R');
api.map('J', 'E');
api.map('H', 'S');
api.map('L', 'D');
api.unmap('R');
api.unmap('E');
api.unmap('S');
api.unmap('D');

// addSearchAliasX('d', 'duckduckgo', 'https://duckduckgo.com/?q=', 'o');

// I don't use bing, baidu for search engine
api.removeSearchAlias('b');
api.removeSearchAlias('w');


// instead, add githu[b],[n]aver
api.addSearchAlias('b', 'github', 'https://github.com/search?q=');
api.addSearchAlias('w', '나무위키', 'https://namu.wiki/w/');

// set default search engines as duckduckgo
settings.defaultSearchEngine = 'd';

// omnibar mappings
api.cmap('<Ctrl-j>', '<Tab>');
api.cmap('<Ctrl-k>', '<Shift-Tab>');

// url edit in vim mode
api.map('U', ';u')
