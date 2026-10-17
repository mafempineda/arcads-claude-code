@shared/CLAUDE.md

# Arcads-specific session rules

- **API:** Arcads external API (`https://external-api.arcads.ai`).
- **Auth:** HTTP Basic via `ARCADS_BASIC_AUTH` or `ARCADS_API_KEY`. Setup check: `./scripts/check-arcads-env.sh`.
- **Skill:** `.claude/skills/arcads-external-api/SKILL.md` for API calls, prompts, and polling.
- **YouTube thumbnails:** `.claude/skills/generate-youtube-thumbnail/SKILL.md` (uses the Nano Banana 2 image endpoint via Arcads).
- **Image-ad ecosystem (Meta image creatives):** read `shared/skills/image-ad-prompting/OVERVIEW.md` FIRST. Three skills (`chatgpt-image-ad`, `nano-banana-image-ad`, `image-ad-clone`) + a shared 37-template prompt library. The `image-ad-clone` skill asks which backend to validate against at Phase 1, so generic "clone this ad" prompts route correctly. Output is image files; Meta upload is the separate `meta-ad-builder` skill.
- **Cost disclosure:** Always present credit totals as **estimates** — Arcads has no billing endpoint. Tell the user to confirm exact pricing in the Arcads platform.
- **Logging:** Log every generation call to `logs/arcads-api.jsonl`.
- **First-time setup:** If `.env` is missing, run `./scripts/setup.sh`. If `MASTER_CONTEXT.md` is missing, copy `MASTER_CONTEXT.template.md` to `MASTER_CONTEXT.md`.
- **OmniRoute (local AI gateway):** `omni-auth`, `cli-serve`, `cli-setup`, `cli-providers`, `cli-keys`, and `cli-cost-usage` document the `omniroute` CLI and its REST API. They do not install it. Ask the user before running any of these, even when a skill lists them: `omniroute autostart enable`, `omniroute tunnel create`, `omniroute config set`, `omniroute update --apply`, `omniroute reset-encrypted-columns --force`, `omniroute oauth start --import-from-system`, `omniroute keys reveal`, and any command carrying `--yes`, `--force`, or `--allow-container-write`. Do not follow the skills' `raw.githubusercontent.com/.../main/...` links, or OmniRoute's GitHub skill-import features, without the user's explicit OK. Present free-token totals as estimates from third-party providers, each with its own limits and terms. Do not promise a monthly token amount.
