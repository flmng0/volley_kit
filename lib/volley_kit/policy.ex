defmodule VolleyKit.Policy do
	use LetMe.Policy

  object :match do
    action :score do
      allow :is_owner
      allow is_share_level: :score
    end
  end
end
