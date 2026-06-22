# 👤 Example profiles (RoleRadar works for any field)

RoleRadar isn't security-specific. The scoring rubric and the CV/cover-letter prompts adapt to **whatever
profile you give them**. To use a different field, paste your own version of these two config fields in the
Phase 3 `Set Job ID` node (and mirror the profile in Phase 2's `Set Candidate Profile`):

- **`FULL_CV_CONTEXT`** — your background (summary, experience, education, certifications).
- **`SKILLS`** — your grouped skillset (the source of truth for skill matching).

Below are short, ready-to-adapt examples for four very different careers. Replace the details with your own —
**use only true facts** (RoleRadar never invents; neither should you).

---

## ⚖️ Corporate Lawyer

**FULL_CV_CONTEXT**
```
Name: Jordan Avery
Current Title: Senior Associate, Corporate / M&A
Location: London, UK
Experience: 8 years in corporate law (M&A, private equity, commercial contracts)

[SUMMARY]
Corporate lawyer with 8 years advising on M&A, joint ventures and commercial contracts for mid-market and
PE-backed clients. Leads deals end to end, from due diligence to completion, and mentors junior associates.

[EXPERIENCE]
Senior Associate — Hartwell & Crane LLP, London (2019–Present)
- Advise on cross-border M&A and private equity transactions
- Lead due diligence teams and draft/negotiate SPAs and shareholder agreements
- Mentor trainees and run the firm's contract-automation pilot

Associate — Bramley Legal, London (2016–2019)
- Drafted commercial contracts and supported corporate transactions

[EDUCATION] LLB, University of Manchester; LPC, BPP Law School
[ADMISSIONS] Solicitor, England & Wales
```
**SKILLS**
```
Practice areas: M&A, private equity, joint ventures, commercial contracts, corporate governance
Drafting & negotiation: SPAs, shareholder agreements, NDAs, due diligence reports
Tools: iManage, HighQ, Luminance, MS Office
Soft skills: client management, deal leadership, mentoring, legal research
Languages: English (native), French (working)
```

---

## 🍳 Head Chef

**FULL_CV_CONTEXT**
```
Name: Sam Rivera
Current Title: Head Chef
Location: Austin, TX
Experience: 12 years in professional kitchens, 5 leading the line

[SUMMARY]
Head chef with 12 years across fine-dining and high-volume restaurants, running kitchens of up to 18 staff.
Builds seasonal menus, controls food cost, and trains teams to a consistent standard.

[EXPERIENCE]
Head Chef — Marigold, Austin (2020–Present)
- Run all kitchen operations, menu design and supplier relationships
- Manage food cost and rotas; train and develop junior chefs
Sous Chef — Cedar & Salt, Austin (2016–2020)
- Led service on the hot section; covered head chef duties

[EDUCATION] Diploma in Culinary Arts, Le Cordon Bleu
[CERTIFICATIONS] ServSafe Manager; Food Handler
```
**SKILLS**
```
Cuisine: modern American, seasonal/farm-to-table, fine dining, high-volume service
Kitchen leadership: menu development, food-cost control, rota/scheduling, supplier management, HACCP
Stations: grill, sauté, pastry basics, butchery
Soft skills: team training, service under pressure, consistency, health & safety
```

---

## 🎨 UX Designer

**FULL_CV_CONTEXT**
```
Name: Priya Nair
Current Title: Senior UX Designer
Location: Remote (EU)
Experience: 7 years in product/UX design for SaaS and mobile

[SUMMARY]
Senior UX designer who turns messy problems into simple, usable products. Owns research, flows and UI, and
partners closely with product and engineering to ship.

[EXPERIENCE]
Senior UX Designer — Lumen SaaS (2021–Present)
- Lead end-to-end design for the core product; run usability testing and a design system
Product Designer — Northwind Apps (2018–2021)
- Designed mobile flows and shipped iterative improvements with the team

[EDUCATION] BA Interaction Design
```
**SKILLS**
```
Design: user research, wireframing, prototyping, interaction design, design systems, accessibility (WCAG)
Tools: Figma, FigJam, Maze, Notion, basic HTML/CSS
Methods: usability testing, journey mapping, A/B testing, design sprints
Soft skills: cross-functional collaboration, stakeholder communication, mentoring
```

---

## 🩺 Registered Nurse

**FULL_CV_CONTEXT**
```
Name: Alex Okafor
Current Title: Registered Nurse (Med-Surg)
Location: Manchester, UK
Experience: 6 years in acute hospital settings

[SUMMARY]
Registered nurse with 6 years in busy med-surg and post-op wards. Calm under pressure, strong on patient
safety and clear handovers.

[EXPERIENCE]
Registered Nurse — St. Brigid's Hospital (2019–Present)
- Deliver post-operative and acute medical care; coordinate with the multidisciplinary team
- Precept new starters and student nurses

[EDUCATION] BSc Nursing
[REGISTRATION] NMC registered
```
**SKILLS**
```
Clinical: med-surg, post-op care, wound care, IV therapy, patient assessment, medication administration
Systems: EPR/EHR documentation, care planning
Soft skills: patient communication, teamwork, handover/SBAR, mentoring students
Compliance: infection control, safeguarding, BLS/ILS
```

---

### After swapping the profile
- Update `CANDIDATE_NAME`, `CANDIDATE_EMAIL`, `CANDIDATE_PHONE`, `CANDIDATE_LINKEDIN`, `CANDIDATE_LOCATION`.
- Set your `Filter` tab searches to your field's job titles.
- Pick a `CV_TEMPLATE` that suits you (or leave `auto`). See [CVs & cover letters](CV_AND_COVER_LETTERS.md).
