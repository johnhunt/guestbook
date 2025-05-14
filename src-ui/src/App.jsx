import { useState, useEffect } from 'react'
import guestbookHero from './assets/guestbook-hero.png'
import './App.css'

function App() {
  const apiEndpoint = import.meta.env.VITE_API_HOST

  const [messages, setMessages] = useState([])
  const [name, setName] = useState('')
  const [comment, setComment] = useState('')

  // get messages from the API
  const getMessages = async () => {
    try {
      const response = await fetch(`${apiEndpoint}/guestbook`)
      const data = await response.json()
      // Sort messages by created_at in descending order (newest first)
      const sortedMessages = data.entries.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
      setMessages(sortedMessages);
    } catch (err) {
      console.error('Error fetching messages:', err)
    }
  }

  // fetch messages on initial load
  useEffect(() => {
    getMessages()
  }, [])

  // post a message to the API
  const postMessage = async () => {
    if (!name.trim() || !comment.trim()) return
    try {
      await fetch(`${apiEndpoint}/guestbook`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, comment }),
      })
      setName('')
      setComment('')
      await getMessages() // Refresh messages after posting
    } catch (err) {
      console.error('Error posting message:', err)
    }
  }

  const handleSubmit = (event) => {
    event.preventDefault() // Prevent the default form submission
    postMessage()
  }

  return (
    <>
      <div>
        <img src={guestbookHero} className="logo" alt="Sign the guestbook" />
      </div>
      <form onSubmit={handleSubmit}>
        <input
          type="text"
          placeholder="Name"
          value={name}
          onChange={(e) => setName(e.target.value)}
        />
        <input
          type="text"
          placeholder="Comment"
          value={comment}
          onChange={(e) => setComment(e.target.value)}
        />
        <button type="submit">Sign</button>
      </form>
      <h2>Messages</h2>
      <ul id="messages">
        {messages.map((msg, idx) => (
          <li key={idx}>
            <strong>{msg.name}</strong>:<br />
            {msg.comment}<br />
            <small>Created at: {new Date(msg.created_at).toLocaleString()}</small>
          </li>
        ))}
      </ul>
    </>
  )
}

export default App
