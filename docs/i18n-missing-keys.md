# Localization gap report — intl strings with no CMS key

Generated from the 225 `S.of(context)` calls vs the live `/content` map (685 keys).
Only strings with a confident CMS match can be migrated to `t()`; the rest below
need a CMS key added on the backend (then they can be migrated). Month/day names are
intentionally excluded — those must come from `DateFormat`, not CMS.

## Covered by CMS (25) — safe to migrate now

- `block.loading_more` ← intl `bgfbgfb4` — Loading...
- `chat.input.placeholder` ← intl `hrt4h5hte43h454` — Write a message
- `chat.list.title` ← intl `mjhmhjmj5` — Chats
- `common.error` ← intl `somethingWentWrong` — Something went wrong
- `create.flight_time` ← intl `trh34tgvrt4h3g4rwev` — h
- `deals.action.cancel` ← intl `cancel` — Cancel
- `deals.retry` ← intl `retry` — Retry
- `deals.role.sender` ← intl `fvvdf` — sender
- `deals.section.history` ← intl `bfdgbt5` — History
- `enum.referral_status.flagged` ← intl `juty4545` — Under review
- `enum.review_status.approved` ← intl `hgterfvb4btgv` — Verified
- `legal.privacy.title` ← intl `privacyPolicy` — Privacy policy
- `menu.change_password` ← intl `brttt4htg3rfwd` — Change password
- `menu.edit_profile` ← intl `vfgbhyujkerg3` — Edit profile
- `menu.email` ← intl `emailg34rfvfs` — Email
- `menu.privacy` ← intl `vsf3r4gh57j6hnbd` — Privacy
- `menu.section_account` ← intl `vfdvfdvfd` — Account
- `notification.account_verified.title` ← intl `bdfdw432534vfd` — Account verified
- `notifications.title` ← intl `jyntytrk5j34r` — Notifications
- `search.button` ← intl `searchbtrrevfdsc` — Search
- `search.from_placeholder` ← intl `bgfbgf534tg534g` — From
- `search.from_placeholder` ← intl `btrb4tdb4tbr` — From
- `search.to_placeholder` ← intl `bry5yn4ny4bde` — To
- `search.to_placeholder` ← intl `greg54eh3rwgs` — To
- `verification.status_title` ← intl `gdfgdf4343gre` — Verification status

## Missing in CMS (200) — backend needs to add keys

| EN text | uses | intl key (obf) |
|---|---|---|
| min | 6 | `vre3gg43gv3r3v3rv` |
| Hide | 2 | `fgsdgsgdfs` |
| Select | 2 | `nhgngn5` |
| Select | 2 | `gbfbgfbfg4` |
| Show more | 2 | `bgfdbssdbd` |
| kg | 2 | `kq` |
| year | 2 | `fregt56hgte` |
| . The communication takes place directly between users and the site is not responsible for the content of the correspondence. | 1 | `brtevrfg45rfs` |
| About | 1 | `vrevre43` |
| Account verification | 1 | `gre43fbd4t3` |
| All checks passed | 1 | `vfvfd443r43` |
| Application under review | 1 | `vdfvfd42422` |
| Apply | 1 | `bnht` |
| Apply | 1 | `bgfbggfbfg3` |
| Apr | 1 | `d2edf3f34` |
| Aug | 1 | `f3f3r5gf34fr34` |
| Awaiting results | 1 | `hy4345` |
| Azerbaijani | 1 | `azrbaycan` |
| Camera | 1 | `camera` |
| Choose Image | 1 | `chooseImage` |
| Cities not found | 1 | `tyju65y4htge3rwfs` |
| Cities not found | 1 | `nthybgtefr4terfd` |
| Code: | 1 | `bmy5` |
| Communication languages | 1 | `nybhtgr54terfw3` |
| Communication languages | 1 | `ki7ju6h5ytg4erf53fw` |
| Confirm new password | 1 | `jyrtj57jhrttyh4te` |
| Contact information | 1 | `bteg4r5344wfvsfdg34wf` |
| Current password | 1 | `htrh64h5tger` |
| Date: | 1 | `te3g35grfgsg` |
| Dec | 1 | `gregerrg33gr` |
| Deliveries | 1 | `tbgverfsdclk345frwcs` |
| Delivery: | 1 | `btegw4er4tgwr45g` |
| Details | 1 | `etg5g43gdg` |
| Document verification takes 1-3 business days. After approval, you will receive the status  | 1 | `grgdfgdfg34t343t` |
| Documents approved | 1 | `vfdvfdr3r34` |
| Documents submitted | 1 | `vfdvfd22343` |
| Documents successfully submitted for review | 1 | `yhtjkuyil43` |
| English | 1 | `english` |
| Enter current and new password | 1 | `brtb5h6h453grbegr` |
| Enter your message... | 1 | `rthh4ger34f34` |
| Error | 1 | `bfdbsdbadfb` |
| Error loading languages: | 1 | `vdfvfd4rg5ger` |
| Error loading package types: | 1 | `vfdvd54gves` |
| Error sending message: | 1 | `vreevrrvrrvrevre` |
| Error: | 1 | `vdf3fg3rvs` |
| Error: | 1 | `fvdvefr34vfsvd` |
| Error: | 1 | `veferv3e4ver` |
| Experience data saved | 1 | `bgfb4tr3getbger` |
| Feb | 1 | `f434f3vgterf43` |
| Flight date: | 1 | `bbrgtrewrg3v` |
| Flight number | 1 | `flightNumber` |
| Full name | 1 | `vrebveg34g3sd` |
| Gallery | 1 | `gallery` |
| Given | 1 | `gert3tger` |
| Hide | 1 | `gdreg53ge` |
| History is empty | 1 | `gbdyh5g` |
| Identity verification | 1 | `bfxvdg34` |
| Important: | 1 | `gbdgb3434` |
| Insurance | 1 | `nrny5nrnrny5n5y454` |
| Insurance | 1 | `brtg3rtvebt4rgvbfd` |
| Insurance ( | 1 | `vevrtbgvt5ybtvew` |
| Invalid time format: | 1 | `vfdv3rgfre42` |
| Invalid time format: | 1 | `vfd3fggvrgds` |
| Jan | 1 | `frg4543gr3gwgr3` |
| Jul | 1 | `f34f34f3r4fr3` |
| Jun | 1 | `f3rfr3vf3ref3d` |
| Languages loading. Try again later. | 1 | `vfd34` |
| Languages not found | 1 | `bdg3` |
| Languages not loaded. Try again later. | 1 | `bgdfbgfd3` |
| Last seen | 1 | `btergwfe5g34rfecerv` |
| Location | 1 | `bebfdb34g3vs` |
| Login | 1 | `loginrbvgefrds` |
| Main document | 1 | `vdfvbfd34` |
| Manage information visibility | 1 | `vfsvf33fr` |
| Mar | 1 | `f3f43fr34g345g54h` |
| Marketing notifications | 1 | `bfvdeb3gg34` |
| Max weight | 1 | `brthgteb4h5g4t35g` |
| Maximum weight | 1 | `evr4g653twgrv43gr` |
| Maximum weight (kg) | 1 | `brbt444b3tgsdgetr` |
| May | 1 | `ff3rfr34f3erf3r` |
| Message sent! | 1 | `ybrfsg4t34gtgrvfedvfd` |
| Minimum 6 characters | 1 | `bgrtyhnyn5jh4g3` |
| New messages | 1 | `trbgtvrger56fd` |
| New password | 1 | `htrh56h5656` |
| New reviews | 1 | `ger4tr3345` |
| No active offers | 1 | `ynbreg4t3gfwr3gf` |
| No internet connection | 1 | `noInternetConnection` |
| No reviews | 1 | `bgrfw3542rfsd` |
| No reviews given | 1 | `bvfdgb43` |
| No reviews given | 1 | `bfdtw4ew4` |
| Not uploaded | 1 | `fbdbdf3434` |
| Not uploaded | 1 | `yghtrdf4343` |
| Nov | 1 | `frefr3rf2343fr4` |
| OK | 1 | `ok` |
| Oct | 1 | `frrf33frf34fr3` |
| On platform | 1 | `btegr4tfwrg3frwv` |
| On time | 1 | `ntnhnhry454` |
| On-time deliveries | 1 | `tegr4rt3542frg3r` |
| Package type: | 1 | `nhgnhg4` |
| Package types loading. Try again later. | 1 | `t53grvfe5` |
| Package types not found | 1 | `bgbffgb3` |
| Package types not loaded. Try again later. | 1 | `bgfbgfbgf4` |
| Package types unavailable on server | 1 | `trh35hteh354heh` |
| Passport | 1 | `vfd43vfd` |
| Passport and selfie received | 1 | `vfd233424` |
| Password successfully changed | 1 | `vfegt4g3rvsfcfd` |
| Phone | 1 | `vsf3grevsf43` |
| Phone | 1 | `tbergwf35grwfsvfg43` |
| Please enter a message | 1 | `by5htg4refg4tr3few` |
| Please select a rating | 1 | `rynryyrynrh444646` |
| Please upload both documents | 1 | `bgfbgd3ttgtebdsdf` |
| Price range ($/kg) | 1 | `bgdbtb4brgd` |
| Price range ($/kg) | 1 | `vervrefg3gr45t3t4fwr34` |
| Price: | 1 | `rggre5egre` |
| Privacy and notifications | 1 | `gret4h5h53g2b` |
| Professional information | 1 | `bterv4gg353r5r35` |
| Purchase date: | 1 | `ger4w53g3tgsg` |
| Rate courier | 1 | `ntnyyh4664bnrgn` |
| Received | 1 | `hbfgh3` |
| Repeat new password | 1 | `jytuj56j56jj45` |
| Response | 1 | `brh45hg43g4tgve` |
| Response time | 1 | `btrg3243g5vfed34ft` |
| Review History | 1 | `listingHistory` |
| Route: | 1 | `getgrw35g3egeg3eg` |
| Russian | 1 | `rudssian` |
| Save changes | 1 | `gbd423g54bd` |
| Save changes | 1 | `grvge3g5` |
| Save changes | 1 | `htrh4hedh4th4` |
| Save new password | 1 | `jt676676756jhr` |
| Saved | 1 | `greg5g4g4g3` |
| Saved | 1 | `gregre3rg` |
| Saved | 1 | `nyh5jj53ge` |
| Search city... | 1 | `hyrh5h4tgerwfs` |
| Search city... | 1 | `nu6j5yhtge65h4tgre` |
| Search country... | 1 | `mjh5y` |
| Select at least one language | 1 | `vfd3rvewr3r` |
| Select at least one specialization | 1 | `yhthrgtr35hg4gd` |
| Select city | 1 | `bgrhtrgrfr445` |
| Select city | 1 | `tnhyj5brgbdfg` |
| Select country | 1 | `nbtynt7` |
| Select language | 1 | `bgfbgfbg33344343` |
| Select languages | 1 | `bgvfd3` |
| Select specialization | 1 | `bfgbgfb3` |
| Selected experience: | 1 | `bgdretr35grdf` |
| Selfie with passport | 1 | `gfdfd3434` |
| Send | 1 | `brg353gffvw34fr3` |
| Sep | 1 | `f3rf3r4fder3` |
| Show | 1 | `grg34g54gdgdg` |
| Show activity time | 1 | `bgfbgt4ry46hj57jhg` |
| Show all | 1 | `bgnhju46` |
| Show email | 1 | `emailnhrtybe` |
| Show phone | 1 | `myiuk7564hd` |
| Specialization | 1 | `greg3greg43grgre` |
| Start typing city name | 1 | `juu76j5yh4rtge` |
| Submit | 1 | `nhtnhtnyth4465645` |
| Submit for review | 1 | `bfdbffd24343vfd` |
| Success! | 1 | `bfdbdffbdsbf` |
| Successful | 1 | `mftdr4587vfg` |
| Tap to change photo | 1 | `bvfdb4btevsf` |
| Thank you for your review! | 1 | `gergergre335345` |
| Time: | 1 | `gerg3g3ge` |
| Turkish | 1 | `turkish` |
| Ukrainian | 1 | `ukrainskiy` |
| Unknown language | 1 | `nhtg5` |
| Upload documents for verification | 1 | `get42fvfdvs` |
| Upload passport | 1 | `bdf234rffd` |
| Upload selfie with passport | 1 | `fdggg35tr34g` |
| Uploaded | 1 | `gdf43gf` |
| Uploaded | 1 | `hrgrs434` |
| User | 1 | `vfewrerewec` |
| User | 1 | `gte34rte5rg5er` |
| Verification | 1 | `bd3435fvd` |
| Verification | 1 | `vfdgfdvfd42343` |
| Verification | 1 | `gregrere4334` |
| Verification completed | 1 | `gttbr42435t345` |
| Verified | 1 | `ge35e5g3gerg3` |
| Verify your identity to increase
trust | 1 | `ngre24532vfds` |
| We will notify you of the verification results | 1 | `gtrgtr34343` |
| Weight: | 1 | `gerg3g53grg` |
| Work experience | 1 | `bryh4tb4thb4yhhe` |
| Work experience | 1 | `bteettgr3gt4g3t4tg3` |
| Working hours | 1 | `nujnhry4hrt` |
| Working hours | 1 | `beg53gt342feg35g2fw` |
| Write | 1 | `nrhnnryhtnyr464` |
| Write | 1 | `grt4g4gdeg354` |
| Write your comment... | 1 | `nhthnnhthnty554y54y` |
| You are communicating directly with the user | 1 | `rth435gtre` |
| You are verified! | 1 | `vfdfv22434` |
| You can use all platform features | 1 | `dfbdf424fdv` |
| Your account has been successfully verified.
You now have the status  | 1 | `vfdvfdvfvfdewr44` |
| Your verification application has been successfully submitted.
We will review your documents within 1-3 business days. | 1 | `n13vdf43` |
| buyer | 1 | `fvgbfdb` |
| courier | 1 | `frefd` |
| days | 1 | `etghrwf3fr3` |
| kg | 1 | `hyrhh6g453grth4ge` |
| kg | 1 | `ethgr46htgbevgte` |
| reviews) | 1 | `y5rbtvfs4l53` |
| years | 1 | `myijtyhg34ewfrv` |
| years | 1 | `tebh4gterw4htgerwf` |
| 🟢 Verified | 1 | `fvdgd` |
