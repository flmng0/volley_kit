# Volley

Relatime, synchronised, self-hostable **Volley**ball scoring toolkit.

## Notes to Self

Currently Needs Work:

- [x] Implement syncrhonisation (PubSub) functionality
- [x] Start testing of scoring logic
- [ ] Implement scorer/password flow.


### Scorer token association:

#### Use a many_to_many association via a Schema.

This allows for ownership level to be configured via the join_through schema.

(Rather than have a `has_one :owner` and `has_many :scorers`)

This would also enable one user to be able to score / own multiple matches.

