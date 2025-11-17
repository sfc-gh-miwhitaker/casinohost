# 03 – Demo Usage & Narrative

## Goal
Guide presenters and casino hosts through the storyline, Cortex Analyst queries, and operational talking points for the demo experience.

Estimated time: 10 minutes

## Characters & Personas
- **Marcus Chen** – Diamond “whale” missing expected visits (retention story)  
- **Jennifer Martinez** – Rising slot player showing rapid growth (development story)  
- **David Thompson** – At-risk table regular with declining frequency (win-back story)

## Demo Script (15 minutes)
1. **Opening (2 min)**  
   - Introduce the casino host command center powered by Snowflake  
   - Highlight consolidation of gaming, comps, and ML-driven guidance
2. **Marcus – Urgent Retention (5 min)**  
   - Query: “Show high-value players at risk of churning”  
   - Analyst returns Marcus with 0.72 churn probability and VIP LTV segment  
   - Recommended action: premium comp bundle → discuss ROI vs theoretical value
3. **Jennifer – Tier Development (4 min)**  
   - Query: “Which growth players deserve a tier review?”  
   - Note increasing sessions, positive response to comps, propose proactive upgrade  
   - Show LTV quintile and host touches driving loyalty
4. **David – Win-back Strategy (3 min)**  
   - Query: “List players absent for 30 days with prior host touches”  
   - Outline targeted comeback offer and responsible gaming reminder  
   - Emphasize comp reinvestment percentages (25-40% of theoretical)

## Cortex Analyst Query Starter Pack
- “Which players should I offer comps to right now and why?”  
- “Summarize churn risk for Platinum tier players this week.”  
- “What is the average theoretical per session for Marcus Chen?”  
- “Who redeemed less than $50 in comps over the last 30 days?”  
- “Explain the recommendation reason for player {{player_id}}.”

## Host Workflow Tips
- Run verified queries first, then follow-up freeform prompts for narrative color  
- Use suggested comp values but tailor with host discretion (budget thresholds)  
- Document interactions in CRM referencing `CASINO_HOST_ANALYST` outputs  
- Reinforce responsible gaming: flag anomalous play during conversations

## Troubleshooting
- **Analyst returns empty set** → Confirm deployment executed and role is `CASINO_HOST_ANALYST`  
- **Response latency >5s** → Check if warehouse auto-suspended; resume `SFE_CASINO_HOST_WH`  
- **Unexpected recommendation** → Review `V_PLAYER_FEATURES` inputs; regenerate data if needed  
- **Persona not appearing** → Use direct `WHERE player_id = ...` queries to validate underlying data

