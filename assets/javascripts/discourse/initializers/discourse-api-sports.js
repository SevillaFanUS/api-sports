.api-sports-modal {
  .modal-body {
    padding: 0;
  }
}

.api-sports-no-key-warning {
  background: var(--danger-low);
  color: var(--danger);
  padding: 0.75rem 1rem;
  margin-bottom: 1rem;
  border-radius: 4px;
  font-size: 0.9em;
}

.api-sports-modal-layout {
  display: flex;
  gap: 0;
  min-height: 400px;
}

.api-sports-type-list {
  width: 220px;
  min-width: 220px;
  border-right: 1px solid var(--primary-low);
  padding: 1rem 0;
  background: var(--secondary);
}

.api-sports-section-label {
  font-size: 0.75em;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--primary-medium);
  padding: 0.5rem 1rem 0.25rem;
}

.api-sports-type-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  width: 100%;
  padding: 0.5rem 1rem;
  background: none;
  border: none;
  cursor: pointer;
  text-align: left;
  color: var(--primary);
  font-size: 0.875em;

  &:hover {
    background: var(--primary-very-low);
  }

  &.is-active {
    background: var(--tertiary-very-low);
    color: var(--tertiary);
    font-weight: 600;
  }
}

.api-sports-fields-panel {
  flex: 1;
  padding: 1rem;
  overflow-y: auto;
}

.api-sports-type-description {
  color: var(--primary-medium);
  font-size: 0.875em;
  margin-bottom: 1rem;
  line-height: 1.5;
}

.api-sports-quick-ids {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
  margin-bottom: 1rem;
}

.api-sports-chip {
  display: inline-flex;
  align-items: center;
  gap: 0.3rem;
  padding: 0.25rem 0.6rem;
  background: var(--primary-very-low);
  border: 1px solid var(--primary-low);
  border-radius: 12px;
  cursor: pointer;
  font-size: 0.8em;

  &:hover {
    background: var(--tertiary-very-low);
    border-color: var(--tertiary-low);
  }
}

.api-sports-chip-id {
  color: var(--primary-medium);
  font-family: monospace;
}

.api-sports-field {
  margin-bottom: 0.75rem;
}

.api-sports-field-label {
  display: block;
  font-size: 0.875em;
  font-weight: 600;
  margin-bottom: 0.25rem;
}

.api-sports-required {
  color: var(--danger);
  margin-left: 0.2rem;
}

.api-sports-field-input {
  width: 100%;
  padding: 0.4rem 0.6rem;
  border: 1px solid var(--primary-low);
  border-radius: 4px;
  font-size: 0.875em;
  background: var(--secondary);
  color: var(--primary);

  &:focus {
    outline: none;
    border-color: var(--tertiary);
  }
}

.api-sports-validation-error {
  color: var(--danger);
  font-size: 0.875em;
  margin-bottom: 0.75rem;
}

.api-sports-html-preview {
  background: var(--primary-very-low);
  border-radius: 4px;
  padding: 0.6rem 0.8rem;
  margin-top: 0.25rem;

  code {
    font-size: 0.8em;
    word-break: break-all;
    color: var(--primary-high);
  }
}
