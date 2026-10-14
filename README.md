# European Retail Analytics & Financial Reporting Layer

## Business Problem & Context
**Domain:** Cross-Border E-Commerce & Retail Finance  
**Markets:** Germany (DE), United Kingdom (UK), Switzerland (CH), Poland (PL)

In multi-market retail, regional performance tracking is routinely distorted by disconnected financial rules: local managers evaluate gross commercial revenue in regional currencies (EUR, GBP, CHF, PLN), while central leadership reports net financial performance in EUR. 

Compounded by unbridged foreign exchange gaps over non-trading days, dynamic point-in-time promotional markdowns, and time-varying regional VAT jurisdictions, this operational divergence drives a recurring monthly misalignment of hundreds of thousands of euros between regional markets and HQ.

## Objective
This platform engineers a unified, audit-ready data layer in dbt that:
- Normalizes multi-currency sales streams using daily ECB rate spines to close exchange rate reporting gaps.
- Preserves point-in-time catalog and promotional pricing history via SCD Type-2 snapshots to prevent margin drift.
- Reconciles dynamic regional VAT boundaries to isolate true net revenue and tax obligations.
- Delivers dimensional star-schema marts optimized for executive-level commercial reporting and audit compliance.

---
*Detailed architecture, data lineage, and testing documentation coming soon.*

