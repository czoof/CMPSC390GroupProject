document.addEventListener("DOMContentLoaded", () => {
  let deleteTargetId = null;

  const modal = document.getElementById("deleteModal");
  const confirmBtn = document.getElementById("confirmDeleteBtn");
  const cancelBtn = document.getElementById("cancelDeleteBtn");
  const form = document.getElementById("newPostForm");
  const discussionList = document.getElementById("discussionList");

  const userId = localStorage.getItem("userId");

  // LOAD discussions (GLOBAL)
  window.loadDiscussions = async function () {
    const res = await fetch("/discussions");
    const data = await res.json();

    discussionList.innerHTML = "";

    data.forEach(post => renderPost(post));
  };

  // LOAD bookmarks (GLOBAL)
  window.loadBookmarks = async function () {
    const res = await fetch(`/bookmarks/${userId}`);
    const data = await res.json();

    discussionList.innerHTML = "";

    data.forEach(post => renderPost(post));
  };

  // AUTO LOAD ON PAGE OPEN
  loadDiscussions();

  // CREATE post
  form.addEventListener("submit", async (e) => {
    e.preventDefault();

    const title = document.getElementById("postTitle").value.trim();
    const content = document.getElementById("postContent").value.trim();

    if (!title || !content) return;

    await fetch("/discussions", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ userId, title, content })
    });

    form.reset();
    loadDiscussions();
  });

  // RENDER post
  function renderPost(post) {
    const div = document.createElement("div");
    div.className = "content-box";
    div.style.marginTop = "12px";

    const currentUserId = localStorage.getItem("userId");

    div.innerHTML = `
      <h3>${post.Title}</h3>
      <p>${post.Content}</p>
      <small>By ${post.UserName}</small><br><br>

      <button onclick="reply(${post.DiscussionID})">Reply</button>

      ${
        post.UserID == currentUserId
          ? `<button onclick="deletePost(${post.DiscussionID})">Delete</button>`
          : ""
      }

      <button onclick="bookmark(${post.DiscussionID})">⭐</button>

      <div id="replies-${post.DiscussionID}"></div>

      <div class="reply-box" style="margin-top:10px;">
      <input 
      type="text" 
      id="reply-input-${post.DiscussionID}" 
      placeholder="Write a reply..."
      class="reply-input"
  />
  <button onclick="submitReply(${post.DiscussionID})">Reply</button>
</div>
    `;

    discussionList.appendChild(div);

    loadReplies(post.DiscussionID);
  }

  // LOAD replies
  async function loadReplies(id) {
    const res = await fetch(`/discussions/${id}/replies`);
    const replies = await res.json();

    const container = document.getElementById(`replies-${id}`);
    container.innerHTML = "";

    replies.forEach(r => {
  const p = document.createElement("p");
  p.innerHTML = `<strong>${r.UserName}:</strong> ↳ ${r.Content}`;
  container.appendChild(p);
});
  }

  // REPLY
  window.submitReply = async (id) => {
  const input = document.getElementById(`reply-input-${id}`);
  const content = input.value.trim();

  if (!content) return;

  await fetch(`/discussions/${id}/replies`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ userId, content })
  });

  input.value = "";
  loadDiscussions();
};

  // DELETE
  window.deletePost = async (id) => {
    
    window.deletePost = (id) => {
    deleteTargetId = id;
    modal.classList.remove("hidden");
};
    console.log("Deleting with:", userId);

    const res = await fetch(`/discussions/${id}`, {
      method: "DELETE",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ userId })
    });

    const data = await res.json();
    console.log("Delete response:", data);

    loadDiscussions();
  };

  // BOOKMARK TOGGLE
  window.bookmark = async (id) => {
    const res = await fetch("/bookmarks", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ userId, discussionId: id })
    });

    const data = await res.json();
    console.log("Bookmark result:", data);

    loadDiscussions();
  };

  confirmBtn.addEventListener("click", async () => {
  if (!deleteTargetId) return;

  const res = await fetch(`/discussions/${deleteTargetId}`, {
    method: "DELETE",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ userId })
  });

  const data = await res.json();
  console.log("Delete response:", data);

  modal.classList.add("hidden");
  deleteTargetId = null;

  loadDiscussions();
});

cancelBtn.addEventListener("click", () => {
  modal.classList.add("hidden");
  deleteTargetId = null;
});
});