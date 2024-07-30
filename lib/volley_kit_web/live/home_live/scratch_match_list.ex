defmodule VolleyKitWeb.HomeLive.ScratchMatchList do
  use VolleyKitWeb, :live_component

  alias VolleyKit.Manager
  alias VolleyKitWeb.HomeLive

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(%{user_id: user_id} = _assigns, socket) do
    scratch_matches = Manager.list_scratch_matches(user_id)

    socket =
      socket
      |> stream(:scratch_matches, scratch_matches)
      |> assign(:user_id, user_id)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <nav>
      <HomeLive.section_card
        title="Your Scratch Matches"
        subtitle="Return to, or view, ongoing scratch matches that you have created in the past."
      >
        <ul class="flex flex-col gap-8" phx-update="stream" id="scratch-matches-list">
          <li
            id="scratch-matches-list-empty"
            class="only:block hidden py-4 px-4 bg-gray-100 text-center rounded-md"
          >
            <p class="italic">Uh oh! You haven't started any matches yet!</p>
          </li>

          <li
            :for={{dom_id, m} <- @streams.scratch_matches}
            id={dom_id}
            class="grid grid-cols-[1fr_auto] gap-3"
          >
            <.link
              navigate={~p"/scratch/#{m.id}"}
              class="flex flex-row justify-evenly w-full hover:bg-zinc-700 bg-gray-900 text-white rounded-md px-4 py-4"
            >
              <span><%= m.options.a_name %></span>
              <span>v.</span>
              <span><%= m.options.b_name %></span>
            </.link>

            <.button
              colors="bg-red-600 hover:bg-red-700 text-black"
              class="border-2 border-red-800"
              phx-click="delete"
              phx-value-id={m.id}
              phx-target={@myself}
            >
              <.icon name="hero-trash" />
            </.button>

            <span
              class="col-span-2 text-sm text-gray-500 italic tracking-wide -mt-2 px-2"
              data-time={m.updated_at}
              id={dom_id <> "-last-used"}
              phx-hook="ScratchLastUsed"
            >
              Last Used:
            </span>
          </li>
        </ul>
      </HomeLive.section_card>
    </nav>
    """
  end

  @impl true
  def handle_event("delete", %{"id" => id}, %{assigns: %{user_id: user_id}} = socket) do
    match = Manager.get_scratch_match!(id)

    socket =
      with ^user_id <- match.created_by,
           {:ok, match} <- Manager.delete_scratch_match(match) do
        socket
        |> stream_delete(:scratch_matches, match)
        |> put_flash(
          :info,
          "Successfully deleted match #{match.options.a_name} v. #{match.options.b_name}"
        )
      else
        false ->
          put_flash(socket, :error, "You are not the owner of this match!")

        {:error, _} ->
          put_flash(socket, :error, "Failed to delete match. Unknown error occurred.")
      end

    {:noreply, socket}
  end
end
