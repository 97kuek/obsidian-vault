---
tags:
  - MOC
aliases:
  - 研究A
  - 音源分離研究
  - プロジェクトA
created: 2026-05-09
status: active
---
## 研究概要

- **ウェアラブルマイク2本**（話者A・Bが各自装着）で録った2chステレオ対話から、**正解なし**で2話者を分離する
- 各chは「装着者＝大・近い」＋「相手＝小・遠い漏れ込み」という非対称構造を持ち、この非対称性（ILD）を主たる手がかりにする
- クリーン単独話者コーパス（**JVS**）を伝搬モデルで2ch混合にシミュレーションして**教師モデル**（Early Fusion構造の**TF-Locoformer**）を教師あり学習し、**RemixIT**で教師→生徒へ自己教師あり適応させて**津軽弁実データ**（正解なし）に対応させる

→ 設計の確定版：[[研究設計（パイプライン全体）]]

## 研究目的

- 研究室GPU環境を用いた深層学習音声分離パイプラインの構築・運用スキルの習得
- TF-Locoformer (ESPnet互換版) の2ch拡張（Early Fusion）の実装・習熟
- 正解なし実データ（エゴセントリック津軽弁対話）への自己教師あり適応（RemixIT）の実現可能性検証

## 実験ノート

```dataview
LIST
FROM "10_Projects/プロジェクト研究A"
WHERE contains(tags, "experiment")
SORT date DESC
```

## 設計ノート

- [[研究設計（パイプライン全体）]] — 確定版の全体像（JVS→シミュ→教師→RemixIT→生徒）
- [[教師モデル_EarlyFusion設計]] — 教師モデル（Early Fusion TF-Locoformer）の実装詳細

## 参考論文・リソース

- [[TF-Locoformer_メモ]]
- [[RemixIT_メモ]]
- [[J-CHAT_メモ]]
- [[Transformer_メモ]]
- [[TasNet_メモ]]
- [[Conv-TasNet_メモ]]

## タスク一覧

### Phase1 : 音声分離の基礎理解・環境構築
- [x] [[TasNet_メモ]]
- [x] [[Conv-TasNet_メモ]]
- [x] [[Transformer_メモ]]
- [x] [[TF-Locoformer_メモ]]
- [x] [[J-CHAT_メモ]]
- [x] [[【MOC】B4勉強会]]
- [x] 研究室GPUマシンへのSSH接続・アカウント作成
- [x] CUDA/cuDNN/PyTorch環境の確認
- [x] `Conda`による仮想環境の準備
- [x] GPU動作確認
- [x] 楠さんとの打ち合わせ

### Phase2 : TF-Locoformerのセットアップ
- [x] リポジトリのクローン
- [x] `1. ESPnet compatible code`の依存関係インストール
- [x] ESPnet本体のセットアップ
- [x] 公開済み学習済みモデルでの推論動作確認

### Phase3 : TF-Locoformerの習熟
- [x] ESPnetのrecipe構造(`egs2/`,`conf/`,`local/`,`run.sh`)の把握
- [x] 設定ファイル(`yaml`)の読み書き
- [x] WSJ0-2mix等の標準データセットでの再現実験
- [x] 学習・評価のログとメトリクスの確認方法
- [x] 問題が出やすいポイントの整理(データパス、サンプリングレート、チャネル数など)

> [!info] 現在地（2026-06-17）
> 実装（Phase4）はほぼ完了。**次のアクションは教師モデルの事前学習（Phase5）** ＝先輩依頼の単体精度確認。クリーン単独話者コーパス（JVS）の入手待ち。津軽弁実データ（Phase6）は小川先生に依頼中。
> 実装の全容は [[研究設計（パイプライン全体）]] と GitHub: [97kuek/egocentric-sep](https://github.com/97kuek/egocentric-sep) を参照。

### Phase4 : 実装（2ch拡張・MC-RemixIT・学習基盤）— ほぼ完了
- [x] `MCTFLocoformerSeparator`：Early Fusion（入力Conv2d 2→4ch、本体は単ch版流用）・RI直推定・fixed/PIT選択
- [x] IPDオプション実装（`use_ipd`、4→6ch、cos/sin）— デフォルトoff
- [x] `MCRemixIT` を論文準拠で実装（リミックスのバッチ間シャッフル・α/β独立サンプリング・時間領域SI-SNR・教師更新 sequential/ema）
- [x] `SimulatedEgoMixtureDataset`：伝搬モデル（1/r減衰＋到達遅延、配置は毎サンプルランダム）で2ch混合＋正解生成
- [x] 学習スクリプト一式（`train_teacher.py` / `train_remixit.py` / `separate.py`）
- [x] ESPnet統合（`tasks/enh.py`へseparator登録・`copy_files_to_espnet.sh`・`egs2/egocentric_dialogue`レシピ・`data.sh`に2ch検証/除外セッション機構）
- [x] テスト整備（37ケース・学習パイプラインのスモークテスト含む）
- [x] GPUメモリ実測（RTX 2080Ti 11GB：batch1×4秒/AMP/F=129 → 8.8GB OK。STFT `n_fft=256, hop=128`）

### Phase5 : 教師モデルの事前学習（コーパス到着前にできる｜次のアクション）
- [ ] クリーン単独話者コーパスの入手（**JVS** 第一候補／JSUT／LibriSpeech、16kHz）
- [ ] **教師モデルの事前学習 → `exp/teacher_sim/best.pth`（先輩依頼の単体精度確認）**
- [ ] 除外セッション情報の収集（GoPro代用・コーパス論文 脚注8 → `excluded_sessions.txt`）

### Phase6 : コーパス到着後 — RemixIT適応（生徒モデル＝最終成果物）
- [ ] 津軽弁対話コーパスの入手（ANLP P4-9／小川先生に依頼中）
- [ ] コーパス構造の確認＋`data.sh`修正（2ch・48kHz、話者ペアが train/test に跨らない分割）
- [ ] データ準備の実行（`run.sh --stage 1`、`wav.scp`生成）
- [ ] RemixIT学習（スモーク設定で動作確認 → 本番、教師ckpt必須）
- [ ] 推論・試聴（`separate.py`、教師単体 vs RemixIT後 の聴き比べ）

### Phase7 : 性能改善
- [ ] IPD有効化（`use_ipd: true`）で教師を再学習しベースラインと比較
- [ ] シミュレーション改善：残響付与（pyroomacoustics）・雑音・ジオメトリ実測合わせ・`remix()`へのch間遅延導入
- [ ] フルモデル長時間学習（`n_layers=6, emb_dim=128`, 150エポック）

### Phase8 : 評価・解析・論文
- [ ] 評価：hold-outシミュで SI-SNR/SDR（正解付き）＋ 実データは DNSMOS/MOS主観・ASR下流(WER)
- [ ] アブレーション：Teacher only／+RemixIT／+IPD／sequential vs ema／fixed vs pit
- [ ] 失敗ケースの分析・レポート・スライド作成

## 関連MOC・上位MOC

- 上位: [[【MOC】10_Projects]]
- 関連: [[【MOC】機械学習・深層学習]]

## メモ・気づき

---
**最終更新:** `= this.file.mtime`
