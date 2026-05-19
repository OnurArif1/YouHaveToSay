export interface BackofficeComparisonListItem {
  id: string
  titleTr: string
  titleEn: string
  category: string
  isActive: boolean
  createdAt: string
  optionCount: number
  totalVotes: number
  leftOptionText: string
  rightOptionText: string
}

export interface BackofficeComparisonOption {
  id: string
  textTr: string
  textEn: string
  imageUrl: string | null
  displayOrder: number
}

export interface BackofficeComparisonDetail {
  id: string
  titleTr: string
  titleEn: string
  category: string
  isActive: boolean
  createdAt: string
  options: BackofficeComparisonOption[]
}

export interface ComparisonOptionInput {
  textTr: string
  textEn: string
  imageUrl?: string | null
}

export interface CreateComparisonRequest {
  titleTr: string
  titleEn: string
  category: string
  isActive: boolean
  leftOption: ComparisonOptionInput
  rightOption: ComparisonOptionInput
}

export interface UpdateComparisonRequest {
  titleTr: string
  titleEn: string
  category: string
  leftOption: ComparisonOptionInput
  rightOption: ComparisonOptionInput
}

export interface ComparisonOptionResult {
  optionId: string
  textTr: string
  textEn: string
  voteCount: number
  percentage: number
}

export interface ComparisonResult {
  comparisonId: string
  titleTr: string
  titleEn: string
  totalVotes: number
  options: ComparisonOptionResult[]
}

export interface BackofficePagedResponse<T> {
  items: T[]
  page: number
  pageSize: number
  totalCount: number
  totalPages: number
}

export interface BackofficeDashboard {
  totalComparisons: number
  activeComparisons: number
  inactiveComparisons: number
  totalVotes: number
  comparisonsCreatedThisWeek: number
  averageVotesPerComparison: number
  mostVotedComparisons: BackofficeComparisonListItem[]
  latestComparisons: BackofficeComparisonListItem[]
}

export interface ComparisonsQuery {
  page?: number
  pageSize?: number
  search?: string
  category?: string
  isActive?: boolean
  sortBy?: string
  sortDirection?: string
}

export interface BackofficeUsersSummary {
  totalUsers: number
  totalVoters: number
  totalVotes: number
  averageVotesPerUser: number
  mostActiveVotersCount: number
  newUsersThisWeek: number
  topVoters: {
    email: string
    totalVotes: number
    createdAt: string
    lastVoteAt: string | null
  }[]
}

export interface ApiErrorBody {
  code?: string
  message?: string
}
