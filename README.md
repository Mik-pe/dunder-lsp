# Dunder LSP

Dunder LSP är en fristående språkserver skriven i [Dunder](https://github.com/Mik-pe/dunder). Repot innehåller också syntaxmarkering för `.ddr` i Neovim, VS Code, Zed och Helix. Servern ger diagnostik medan du skriver, komplettering, typinformation vid hovring, gå till definition, dokumentsymboler, kodåtgärder och formatering. Binären länkar samma Dunder-implementation som `dunder lsp` och kommunicerar över stdio.

## Bygg och installera språkservern

En färdig binär för macOS på Apple Silicon eller Linux på ARM64 och x86-64 finns i [GitHub-releasen](https://github.com/Mik-pe/dunder-lsp/releases/tag/v0.1.0). Packa upp arkivet för din plattform och lägg `dunder-lsp` i en katalog i `PATH`.

Installera [Dunder 0.9.0](https://github.com/Mik-pe/dunder/releases/tag/v0.9.0) och Git. Kör sedan följande.

```sh
git clone https://github.com/Mik-pe/dunder-lsp.git
cd dunder-lsp
dunder build --locked
dunder test --locked
dunder install --locked
```

`dunder-lsp --version` visar paketets och Dunders versioner. Ange `dunder-lsp --stdio` som serverkommando i en LSP-klient. Testet startar binären från byggkatalogen och kontrollerar att ett fel visas, försvinner när texten rättas och att servern svarar med dokumentets symboler.

## VS Code

Hämta [Dunder-tillägget för VS Code](https://github.com/Mik-pe/dunder-lsp/releases/download/v0.1.0/dunder-0.1.0.vsix). Kör **Extensions: Install from VSIX…** i kommandopaletten och välj filen, eller använd terminalen.

```sh
code --install-extension dunder-0.1.0.vsix
```

Öppna en `.ddr`-fil. Språkläget **Dunder** använder en TextMate-grammatik och fungerar även utan installerad språkserver.

## Neovim, Zed och Helix

De tre editorerna delar en Tree-sitter-grammatik och samma markeringsregler. Kör från repots rot på macOS eller Linux med Git, en C-kompilator och [Tree-sitter CLI 0.26](https://github.com/tree-sitter/tree-sitter/releases/tag/v0.26.9) i `PATH`.

```sh
dunder run --locked --example prepare-editors
```

### Neovim

Lägg detta i `init.lua` och anpassa sökvägen till repot. Det aktiverar syntaxmarkering när du öppnar en `.ddr`-fil och ansluter språkservern om den finns i `PATH`.

```lua
vim.opt.runtimepath:prepend(vim.fn.expand("~/dev/dunder-lsp/build/nvim"))
vim.filetype.add({ extension = { ddr = "dunder" } })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "dunder",
  callback = function()
    vim.treesitter.start()
    if vim.fn.executable("dunder-lsp") == 1 then
      vim.lsp.start({
        name = "dunder",
        cmd = { "dunder-lsp", "--stdio" },
        root_dir = vim.fs.root(0, "dunder.toml") or vim.fn.expand("%:p:h"),
      })
    end
  end,
})
```

### Zed

Öppna kommandopaletten, välj **zed: install dev extension** och välj katalogen `build/zed` i din klon. Zed bygger grammatikens WebAssembly-modul. Behåll klonen på samma plats medan tillägget är installerat. Efter en uppdatering kör du förberedelsekommandot igen och bygger om tillägget i Zed.

### Helix

Lägg till språkdefinitionen från [languages.toml](editors/helix/languages.toml) i din Helix-konfiguration. Kopiera den byggda parsern och markeringsreglerna till din runtime-katalog.

```sh
runtime_dir="${XDG_CONFIG_HOME:-$HOME/.config}/helix/runtime"
mkdir -p "$runtime_dir/grammars" "$runtime_dir/queries/dunder"
cp build/nvim/parser/dunder.so "$runtime_dir/grammars/"
cp editors/tree-sitter/queries/highlights.scm "$runtime_dir/queries/dunder/"
hx --health dunder
```

## Prova markeringen

Öppna [tests/highlight.ddr](tests/highlight.ddr) i editorn. Provet innehåller en nästlad blockkommentar, en råsträng med citattecken och ett funktionsanrop inuti en interpolerad sträng. Kör grammatikens markeringsprov efter `prepare-editors`.

```sh
(cd build/tree-sitter-dunder && tree-sitter test)
```
