# Barbed contact precision and garage support

Native float positions could leave a zombie microscopically beyond the strict panel contact boundary, causing opposite faces to behave differently. Add a narrow numerical allowance and garage-segment support that keeps attachments alive but suspends contact and hides panels while raised.

Retain native backing damage and existing bounded updates/sprite synchronization. Reuse a transparent atlas pixel without another bitmap. Swinging double gates remain separate. Native coordinate, backing-damage, garage lifecycle and save/reload checks pass; rendered and connected-player acceptance remain pending. See [verification](TEST_v0.2.69.md) and [planning](PLANNING.md).
