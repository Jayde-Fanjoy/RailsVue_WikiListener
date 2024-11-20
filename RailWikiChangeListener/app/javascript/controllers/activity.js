document.addEventListener('DOMContentLoaded', () => {
    let selectedAuthors = [];
    
    var checkboxes = document.querySelectorAll('input[type="checkbox"]');
    checkboxes.forEach(function(checkbox) {
        checkbox.addEventListener('change', () => {
            const authorId = checkbox.id;

           console.log(selectedAuthors)
           console.log(checkbox.id)

            if (!checkbox.checked) {
                selectedAuthors = selectedAuthors.filter((id) => id !== authorId);
            } else {
                selectedAuthors.push(authorId);
            }

            const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute("content");
            // Fetch the feed from the ScyllaDB-backed API
            fetch("/activity_feed", {
                method: "POST",
                headers: {
                  "Content-Type": "application/json",
                  "X-CSRF-Token": csrfToken,
                },
                body: JSON.stringify({ author_ids: selectedAuthors }),
            })
            .then((response) => {
                if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.json();
            })
            .then((data) => {
                const feed = document.getElementById("activity-feed");
                feed.innerHTML = "";
            
                data.forEach((event) => {
                const div = document.createElement("div");
                div.classList.add("event");
                div.innerHTML = `
                    <strong><a href="${event.url}" target="_blank">${event.title}</a></strong>
                    by ${event.author} at ${event.timestamp}
                `;
                feed.appendChild(div);
                });
            })
            .catch((error) => {
                console.error("Error fetching activity feed:", error);
            });
        })
    });
})
