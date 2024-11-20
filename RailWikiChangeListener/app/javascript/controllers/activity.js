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

    /*
    var checkboxes = document.querySelectorAll("input[type=checkbox][name=settings]");
    checkboxes.forEach(function(checkbox) {
        checkbox.addEventListener('change', function() {
            console.log('JLF28 Test');
            if (selectedAuthors.includes(authorId)) {
                selectedAuthors = selectedAuthors.filter((id) => id !== authorId);
              } else {
                selectedAuthors.push(authorId);
              }
        })
    });
    */

})
/*
    document.querySelectorAll(".author").forEach((button) => {
      button.addEventListener("change", () => {
        const authorId = button.dataset.id;
  
        if (selectedAuthors.includes(authorId)) {
          selectedAuthors = selectedAuthors.filter((id) => id !== authorId);
        } else {
          selectedAuthors.push(authorId);
        }
  
        // Fetch the feed from the ScyllaDB-backed API
        axios
          .post("/activity_feed", { author_ids: selectedAuthors })
          .then((response) => {
            const feed = document.getElementById("activity-feed");
            feed.innerHTML = "";
  
            response.data.forEach((event) => {
              const div = document.createElement("div");
              div.classList.add("event");
              div.innerHTML = `
                <strong><a href="${event.url}" target="_blank">${event.title}</a></strong>
                by ${event.author} at ${new Date(event.timestamp * 1000).toLocaleString()}
              `;
              feed.appendChild(div);
            });
          })
          .catch((error) => {
            console.error("Error fetching activity feed:", error);
          });
      });
    });
  });
*/
/*
document.addEventListener("DOMContentLoaded", () => {
    const authorList = document.getElementById("author-list");
    const activityFeed = document.getElementById("activity-feed");
  
    const selectedAuthors = new Set();
  
    authorList.addEventListener("change", (event) => {
      const checkbox = event.target;
      const authorId = checkbox.dataset.authorId;
  
      if (checkbox.checked) {
        selectedAuthors.add(authorId);
      } else {
        selectedAuthors.delete(authorId);
      }
  
      // Fetch the updated activity feed
      fetchActivityFeed();
    });
  
    function fetchActivityFeed() {
      fetch('/activity_feed', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ author_ids: Array.from(selectedAuthors) })
      })
      .then(response => response.json())
      .then(data => updateActivityFeed(data))
      .catch(error => console.error("Error fetching activity feed:", error));
    }
  
    function updateActivityFeed(events) {
      activityFeed.innerHTML = ""; // Clear the current feed
  
      if (events.length === 0) {
        activityFeed.innerHTML = "<li>No events to display.</li>";
        return;
      }
  
      events.forEach(event => {
        const li = document.createElement("li");
        li.textContent = `${event.timestamp}: ${event.title} by ${event.author}`;
        activityFeed.appendChild(li);
      });
    }
  });
  */