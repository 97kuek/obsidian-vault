import { QuartzConfig } from "./quartz/cfg"
import * as Plugin from "./quartz/plugins"

const config: QuartzConfig = {
  configuration: {
    pageTitle: "学習・研究ノート",
    pageTitleSuffix: "",
    enableSPA: true,
    enablePopovers: true,
    analytics: null,
    locale: "ja-JP",
    baseUrl: "97kuek.github.io/obsidian-vault",
    ignorePatterns: [".obsidian", "private", "templates"],
    defaultDateType: "modified",
    theme: {
      fontOrigin: "googleFonts",
      cdnCaching: true,
      typography: {
        // 本文・見出しは日本語の確実な描画のため Noto Sans JP を維持。
        // コードは vault-custom.css と揃えて JetBrains Mono。
        header: "Noto Sans JP",
        body: "Noto Sans JP",
        code: "JetBrains Mono",
      },
      // パレットは Obsidian の vault-custom.css（Anthropic Claude.com 風）に合わせる。
      // light=クリーム #efe9de / ink #141413 / アクセント coral #cc785c。
      // dark はブランドのダークサーフェス #181715 を基調にした暗色版。
      colors: {
        lightMode: {
          light: "#efe9de",
          lightgray: "#e6dfd8",
          gray: "#6c6a64",
          darkgray: "#3d3d3a",
          dark: "#141413",
          secondary: "#cc785c",
          tertiary: "#a9583e",
          highlight: "rgba(204, 120, 92, 0.10)",
          textHighlight: "#f4d35e88",
        },
        darkMode: {
          light: "#181715",
          lightgray: "#2d2b28",
          gray: "#8e8b82",
          darkgray: "#d9d3c7",
          dark: "#f5f1ea",
          secondary: "#e0997b",
          tertiary: "#cc785c",
          highlight: "rgba(224, 153, 123, 0.12)",
          textHighlight: "#b8902f55",
        },
      },
    },
  },
  plugins: {
    transformers: [
      Plugin.FrontMatter(),
      Plugin.CreatedModifiedDate({
        priority: ["frontmatter", "git", "filesystem"],
      }),
      // vault-custom.css と同じく「ライトでも暗いコード窓」にするため、
      // ライト/ダーク両方を暗いテーマに。窓の地色は custom.scss で #181715 に統一。
      Plugin.SyntaxHighlighting({
        theme: {
          light: "github-dark",
          dark: "github-dark",
        },
        keepBackground: false,
      }),
      Plugin.ObsidianFlavoredMarkdown({ enableInHtmlEmbed: false }),
      Plugin.GitHubFlavoredMarkdown(),
      Plugin.TableOfContents(),
      Plugin.CrawlLinks({ markdownLinkResolution: "shortest" }),
      Plugin.Description(),
      Plugin.Latex({ renderEngine: "katex" }),
    ],
    filters: [Plugin.RemoveDrafts()],
    emitters: [
      Plugin.AliasRedirects(),
      Plugin.ComponentResources(),
      Plugin.ContentPage(),
      Plugin.FolderPage(),
      Plugin.TagPage(),
      Plugin.ContentIndex({
        enableSiteMap: true,
        enableRSS: true,
      }),
      Plugin.Assets(),
      Plugin.Static(),
      Plugin.Favicon(),
      Plugin.NotFoundPage(),
    ],
  },
}

export default config
