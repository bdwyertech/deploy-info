Deploy-Info Changelog
=========================
This file is used to list changes made in each version of the `deploy-info` gem.

v0.1.2 (2016-10-31)
-------------------
### Enhancements
- Security: Hide the config endpoint except in development mode

### Bugs Fixed
- Should automatically pick up the JSON config if developing locally and it is inside config/config.json

v0.1.1 (2016-09-06)
-------------------
### Enhancements
- Fix revision retrieval endpoint.  Supports GET or POST methods.  Will return the short SHA value.

v0.1.0 (2016-09-02)
-------------------
- Initial Release
